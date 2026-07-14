//
//  ReusableMediaDownloader.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 14/07/2026.
//  Copyright © 2026 rami.io. All rights reserved.
//

import Foundation

/// Whether the next `/reusablemedia/` fetch should be a full (resumable) fetch or an incremental one.
enum ReusableMediaFetchStrategy: Equatable {
    /// Fetch ordered by creation time, optionally resuming after a previously interrupted full fetch.
    case full(createdSince: String?, resumedGeneratedAt: String?)
    /// Fetch ordered by modification time, since the last completed full/incremental fetch.
    case incremental(updatedSince: String)

    /// Mirrors the Android `ReusableMediaSyncAdapter` watermark strategy: once a full fetch has completed
    /// and a modified watermark is known, switch to incremental fetches - otherwise perform (or resume) a full fetch
    static func decide(lastSyncCreationTime: String?, lastSyncTime: String?) -> ReusableMediaFetchStrategy {
        if lastSyncCreationTime == "complete", let lastSyncTime = lastSyncTime {
            return .incremental(updatedSince: lastSyncTime)
        }
        guard let lastSyncCreationTime = lastSyncCreationTime, lastSyncCreationTime != "complete" else {
            return .full(createdSince: nil, resumedGeneratedAt: nil)
        }
        let components = lastSyncCreationTime.split(separator: "|", maxSplits: 1, omittingEmptySubsequences: false).map(String.init)
        let createdSince = components[0].isEmpty ? nil : components[0]
        let resumedGeneratedAt = components.count > 1 ? components[1] : nil
        return .full(createdSince: createdSince, resumedGeneratedAt: resumedGeneratedAt)
    }
}

/// Downloads and stores `ReusableMedium`s (e.g. barcode cards linked to order positions).
///
/// Servers older than pretix 4.19 do not expose the `/reusablemedia/` endpoint; a `404` response is treated
/// as "feature not available" and completes the operation without an error. Media are never deleted locally.
class ReusableMediaDownloader: APIClientOperation {
    private var firstPageGeneratedAt: String?

    override func start() {
        if isCancelled {
            completeOperation()
            return
        }

        isExecuting = true

        let strategy = ReusableMediaFetchStrategy.decide(
            lastSyncCreationTime: dataStore.lastSyncCreationTime(of: ReusableMedium.self, in: event),
            lastSyncTime: dataStore.lastSyncTime(of: ReusableMedium.self, in: event))

        fetch(strategy)
    }

    private func fetch(_ strategy: ReusableMediaFetchStrategy) {
        switch strategy {
        case .incremental(let updatedSince):
            urlSessionTask = apiClient.getReusableMediaTask(updatedSince: updatedSince) { result in
                self.process(result, strategy: strategy)
            }
        case .full(let createdSince, _):
            urlSessionTask = apiClient.getReusableMediaTask(createdSince: createdSince) { result in
                self.process(result, strategy: strategy)
            }
        }
        urlSessionTask?.resume()
    }

    private func process(_ result: Result<PagedList<ReusableMedium>, Error>, strategy: ReusableMediaFetchStrategy) {
        switch result {
        case .success(let pagedList):
            let isLastPage = pagedList.next == nil
            let isFirstPage = pagedList.previous == nil

            dataStore.store(pagedList.results, for: event)

            switch strategy {
            case .full(_, let resumedGeneratedAt):
                let originGeneratedAt = resumedGeneratedAt ?? (isFirstPage ? pagedList.generatedAt : nil) ?? firstPageGeneratedAt
                if let originGeneratedAt = originGeneratedAt {
                    firstPageGeneratedAt = originGeneratedAt
                }

                if let lastCreated = pagedList.results.last?.created {
                    let createdWatermark = Formatter.iso8601.string(from: lastCreated)
                    let composite = ([createdWatermark] + [firstPageGeneratedAt].compactMap { $0 }).joined(separator: "|")
                    dataStore.setLastSyncCreatedTime(composite, of: ReusableMedium.self, in: event)
                }
            case .incremental:
                if isFirstPage, let generatedAt = pagedList.generatedAt {
                    firstPageGeneratedAt = generatedAt
                }
            }

            if isLastPage {
                if case .full = strategy {
                    dataStore.setLastSyncCreatedTime("complete", of: ReusableMedium.self, in: event)
                }
                if let generatedAt = firstPageGeneratedAt {
                    dataStore.setLastSyncModifiedTime(generatedAt, of: ReusableMedium.self, in: event)
                }
                completeOperation()
            }
        case .failure(let error):
            handle(error)
        }
    }

    private func handle(_ error: Error) {
        switch (error as? APIError) {
        case .notFound, .unchanged:
            break
        default:
            self.error = error
        }
        completeOperation()
    }
}
