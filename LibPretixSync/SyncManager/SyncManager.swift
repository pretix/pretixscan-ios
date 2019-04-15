//
//  SyncManager.swift
//  PretixScan
//
//  Created by Daniel Jilg on 08.04.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

/// Manages a queue of changes to be uploaded to the API.
///
/// - Has sub-objects for queueing uploads and managing downloads
/// - will periodically try to upload the queue to the server
/// - will periodically try to download all (or all new) server data
///
/// - requires a ConfigStore instance from which it retrieves DataStore and APIClient
public class SyncManager {
    private let configStore: ConfigStore

    init(configStore: ConfigStore) {
        self.configStore = configStore

        NotificationCenter.default.addObserver(self, selector: #selector(syncNotification(_:)),
                                               name: syncStatusUpdateNotification, object: nil)
    }

    public enum NotificationKeys: String {
        case model
        case loadedAmount
        case totalAmount
        case isLastPage
    }

    private var lastSynced = [String: String]() { didSet { configStore.dataStore?.storeLastSynced(lastSynced) }}
    private var dataTaskQueue = [URLSessionDataTask]()

    /// Throw away all data and sync fresh
    public func forceSync() {
        lastSynced = [String: String]()
        beginSyncing()
    }

    /// Update Sync
    public func beginSyncing() {
        guard let dataStore = configStore.dataStore else { return }
        lastSynced = dataStore.retrieveLastSynced()

        let firstSyncCompletionHandler: ((Error?) -> Void) = { error in
            guard error == nil else {
                print(error!)
                return
            }
        }

        // First Sync
        if lastSynced[ItemCategory.urlPathPart] == nil {
            // ItemCategory never synced
            queue(task: syncTask(ItemCategory.self, isFirstSync: true, completionHandler: firstSyncCompletionHandler))
        }

        if lastSynced[Item.urlPathPart] == nil {
            // Item never synced
            queue(task: syncTask(Item.self, isFirstSync: true, completionHandler: firstSyncCompletionHandler))
        }

        if lastSynced[Order.urlPathPart] == nil {
            // Item never synced
            queue(task: syncTask(Order.self, isFirstSync: true, completionHandler: firstSyncCompletionHandler))
        }

        queue(task: syncTask(ItemCategory.self, isFirstSync: false, completionHandler: firstSyncCompletionHandler))
        queue(task: syncTask(Item.self, isFirstSync: false, completionHandler: firstSyncCompletionHandler))
        queue(task: syncTask(Order.self, isFirstSync: false, completionHandler: firstSyncCompletionHandler))
    }
}

// MARK: - Notifications
extension SyncManager {
    var syncStatusUpdateNotification: Notification.Name { return Notification.Name("SyncManagerSyncStatusUpdate") }
}

// MARK: - Qeueing
private extension SyncManager {
    func queue(task: URLSessionDataTask?) {
        guard let task = task else { return }
        dataTaskQueue.append(task)
        updateQueue()
    }

    func updateQueue() {
        guard let task = dataTaskQueue.first else { return }
        if task.state == .completed {
            dataTaskQueue.remove(at: 0)
            dataTaskQueue.first?.resume()
        } else if task.state == .suspended {
            task.resume()
        }
    }

    func resetQueue() {
        dataTaskQueue.first?.cancel()
        dataTaskQueue = []
    }

    @objc
    func syncNotification(_ notification: Notification) {
        updateQueue()
    }
}

// MARK: - Syncing
private extension SyncManager {
    func syncTask<T: Model>(_ model: T.Type, isFirstSync: Bool, completionHandler: @escaping (Error?) -> Void) -> URLSessionDataTask? {
        do {
            let event = try getEvent()

            return configStore.apiClient?.getTask(model, lastUpdated: self.lastSynced[model.urlPathPart]) { result in

                guard let pagedList = try? result.get() else {
                    completionHandler(APIError.emptyResponse)
                    return
                }

                // Notify Listeners
                let isLastPage = pagedList.next == nil
                NotificationCenter.default.post(name: self.syncStatusUpdateNotification, object: self, userInfo: [
                    NotificationKeys.model: model.humanReadableName,
                    NotificationKeys.loadedAmount: pagedList.results.count,
                    NotificationKeys.totalAmount: pagedList.count,
                    NotificationKeys.isLastPage: isLastPage])

                // Store Data
                self.configStore.dataStore?.store(pagedList.results, for: event)

                // Callback that we are completely finished
                if isLastPage {
                    self.lastSynced[model.urlPathPart] = pagedList.generatedAt ?? ""
                    completionHandler(nil)
                }
            }
        } catch {
            completionHandler(error)
            return nil
        }
    }
}

// MARK: - Helper Methods
private extension SyncManager {
    func getEvent() throws -> Event {
        guard let event = configStore.event else {
            throw APIError.notConfigured(message: "ConfigStore.event property must be set before calling this function.")
        }

        return event
    }
}
