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

    public func beginSyncing() {
        print("Beginning Syncing Item Categories")
        sync(ItemCategory.self, isFirstSync: false) { error in
            guard error == nil else {
                print(error!)
                return
            }

            print("Beginning Syncing Items")
            self.sync(Item.self, isFirstSync: false) { error in
                guard error == nil else {
                    print(error!)
                    return
                }

                print("Beginning Syncing Orders")
                self.sync(Order.self, isFirstSync: false) { error in

                }
            }
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
