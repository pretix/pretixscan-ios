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
    }

    public enum NotificationKeys: String {
        case model
        case loadedAmount
        case totalAmount
        case isLastPage
    }

    //  TODO: Save this in Config- or Data Store
    private var lastSynced = [String: Date?]()

    public func beginSyncing() {
        let firstSyncCompletionHandler: ((Error?) -> Void) = { error in
            guard error == nil else {
                print(error!)
                return
            }

            self.beginSyncing()
        }

        // First Sync
        if lastSynced[ItemCategory.urlPathPart] == nil {
            // ItemCategory never synced
            sync(ItemCategory.self, isFirstSync: true, completionHandler: firstSyncCompletionHandler)
        } else if lastSynced[Item.urlPathPart] == nil {
            // Item never synced
            sync(Item.self, isFirstSync: true, completionHandler: firstSyncCompletionHandler)
        } else if lastSynced[Order.urlPathPart] == nil {
            // Item never synced
            sync(Order.self, isFirstSync: true, completionHandler: firstSyncCompletionHandler)
        }

    }
}

// MARK: - Notifications
extension SyncManager {
    var syncStatusUpdateNotification: Notification.Name { return Notification.Name("SyncManagerSyncStatusUpdate") }
}

// MARK: - Syncing
private extension SyncManager {
    func sync<T: Model>(_ model: T.Type, isFirstSync: Bool, completionHandler: @escaping (Error?) -> Void) {
        do {
            let event = try getEvent()

            configStore.apiClient?.get(model) { result in

                guard let pagedItemCategories = try? result.get() else {
                    completionHandler(APIError.emptyResponse)
                    return
                }

                // Notify Listeners
                let isLastPage = pagedItemCategories.next == nil
                NotificationCenter.default.post(name: self.syncStatusUpdateNotification, object: self, userInfo: [
                    NotificationKeys.model: model.humanReadableName,
                    NotificationKeys.loadedAmount: pagedItemCategories.results.count,
                    NotificationKeys.totalAmount: pagedItemCategories.count,
                    NotificationKeys.isLastPage: isLastPage])

                // Store Data
                self.configStore.dataStore?.store(pagedItemCategories.results, for: event)

                // Callback that we are completely finished
                if isLastPage {
                    self.lastSynced[model.urlPathPart] = Date()
                    completionHandler(nil)
                }
            }
        } catch {
            completionHandler(error)
            return
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
