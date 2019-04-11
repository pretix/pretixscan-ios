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
}

// MARK: - Notifications
extension SyncManager {
    var itemCategoriesSyncedNotification: Notification.Name { return Notification.Name("SyncManagerItemCategoriesSynced") }
}

// MARK: - Syncing
private extension SyncManager {
    func syncItemCategories(isFirstSync: Bool) throws {
        let event = try getEvent()

        configStore.apiClient?.getItemCategories { result in

            guard let pagedItemCategories = try? result.get() else {
                return
            }

            // Notify Listeners
            let isLastPage = pagedItemCategories.next == nil
            NotificationCenter.default.post(name: self.itemCategoriesSyncedNotification, object: self, userInfo: [
                "loadedAmount": pagedItemCategories.results.count, "totalAmount": pagedItemCategories.count, "isLastPage": isLastPage])

            // Store Data
            self.configStore.dataStore?.store(pagedItemCategories.results, for: event)
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
