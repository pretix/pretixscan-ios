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

private extension SyncManager {
    func syncItemCategories(isFirstSync: Bool) {
        configStore.apiClient?.getItemCategories { result in

            guard let pagedItemCategories = try? result.get() else {
                return
            }

            let isLastPage = pagedItemCategories.next == nil

            
        }
    }
}
