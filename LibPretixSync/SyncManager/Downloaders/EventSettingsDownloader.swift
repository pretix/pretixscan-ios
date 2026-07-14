//
//  EventSettingsDownloader.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 15/07/2026.
//  Copyright © 2026 rami.io. All rights reserved.
//

import Foundation

/// Downloads and stores the event's `EventSettings` (e.g. whether reusable media usage is enforced).
///
/// Servers that do not expose the `/settings/` endpoint return a `404`, which is treated as "feature not
/// available" and completes the operation without an error.
class EventSettingsDownloader: APIClientOperation {
    override func start() {
        if isCancelled {
            completeOperation()
            return
        }

        isExecuting = true

        urlSessionTask = apiClient.getEventSettingsTask(event: event) { result in
            self.process(result)
        }
        urlSessionTask?.resume()
    }

    private func process(_ result: Result<EventSettings, Error>) {
        switch result {
        case .success(let settings):
            dataStore.store([settings], for: event)
            completeOperation()
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
