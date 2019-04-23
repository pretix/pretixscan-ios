//
//  SyncManager.swift
//  PretixScan
//
//  Created by Daniel Jilg on 08.04.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

/// Manages a queue of changes to be up- and downloaded to and from the API.
///
/// - requires a ConfigStore instance from which it retrieves `DataStore` and `APIClient` instances
///
/// - Note: You should almost never have to use the SyncManager directly. Instead, use an instance of `TicketValidator`, which uses
///   `APIClient`, `SyncManager` and `DataStore` in various strategies to get you the result you want.
///
/// ## Triggering Up- and Download Actions
///
/// Calling the `beginSyncing()` method results in SyncManager checking with the server for any new data
/// before beginning to upload any queued up data that is not uploaded yet.
///
/// Use the `forceSync()` method to forcefully redownload all data from the server.
///
/// ## Notifications
///
/// `SyncManager` will send out a Notification named `SyncManager.syncDownloadStatusUpdateNotification` to the default
/// `NotificationCenter` whenever a new page of data has finished downloaded.
///
/// - See also `NotificationKeys`
///
/// Subscribe to it by creating an `@objc` enabled function called e.g. `syncDownloadStatusUpdate` and then calling
/// `NotificationCenter.addObserver` in your init:
///
/// ```swift
/// init() {
///     // ...
///     NotificationCenter.default.addObserver(self, selector: #selector(syncDownloadStatusUpdate(_:)),
///                                            name: configStore.syncManager.syncDownloadStatusUpdateNotification, object: nil)
/// }
///
/// @objc
/// func syncDownloadStatusUpdate(_ notification: Notification) {
///     // ...
/// }
/// ```
public class SyncManager {
    private let configStore: ConfigStore

    init(configStore: ConfigStore) {
        self.configStore = configStore

        NotificationCenter.default.addObserver(self, selector: #selector(syncNotification(_:)),
                                               name: syncDownloadStatusUpdateNotification, object: nil)
    }

    // MARK: - Notifications
    var syncDownloadStatusUpdateNotification: Notification.Name { return Notification.Name("SyncManagerSyncStatusUpdate") }

    /// Notifications sent out by SyncManager
    ///
    /// Usage example:
    ///
    /// ```swift
    /// @objc
    /// func syncDownloadStatusUpdate(_ notification: Notification) {
    ///     let model: String = notification.userInfo?[SyncManager.NotificationKeys.model] as? String ?? "No Model"
    ///     let loadedAmount = notification.userInfo?[SyncManager.NotificationKeys.loadedAmount] as? Int ?? -1
    ///     let totalAmount = notification.userInfo?[SyncManager.NotificationKeys.totalAmount] as? Int ?? -1
    ///     let isLastPage = notification.userInfo?[SyncManager.NotificationKeys.isLastPage] as? Bool ?? false
    ///
    ///     print("\(model) updated, added \(loadedAmount)/\(totalAmount).")
    ///
    ///     if isLastPage {
    ///         print("Finished syncing \(model).")
    ///     }
    /// }
    /// ```
    public enum NotificationKeys: String {
        /// The Model that this notification is about, as a human readable String. E.g. "Order"
        case model

        /// The amount of instances of the model that have been loaded in the last page.
        ///
        /// Note that you'll have to add those up yourself.
        case loadedAmount

        /// The total amount of instances of the model on the server
        case totalAmount

        /// The sync process for this model is completed with this notification
        case isLastPage
    }

    private var lastSynced = [String: String]() { didSet { configStore.dataStore?.storeLastSynced(lastSynced) }}
    private var dataTaskQueue = [URLSessionDataTask]()

    // MARK: - Syncing
    /// Force a complete redownload of all synced data
    public func forceSync() {
        lastSynced = [String: String]()
        beginSyncing()
    }

    /// Trigger a sync process, which will check for new data from the server
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
            // Orders never synced
            queue(task: syncTask(Order.self, isFirstSync: true, completionHandler: firstSyncCompletionHandler))
        }

        queue(task: syncTask(Event.self, isFirstSync: true, completionHandler: firstSyncCompletionHandler))
        queue(task: syncTask(CheckInList.self, isFirstSync: true, completionHandler: firstSyncCompletionHandler))
        queue(task: syncTask(ItemCategory.self, isFirstSync: false, completionHandler: firstSyncCompletionHandler))
        queue(task: syncTask(Item.self, isFirstSync: false, completionHandler: firstSyncCompletionHandler))
        queue(task: syncTask(Order.self, isFirstSync: false, completionHandler: firstSyncCompletionHandler))
    }
}

// MARK: - Queue Management
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

            return configStore.apiClient?.getTask(model, lastUpdated: self.lastSynced[model.urlPathPart],
                                                  isFirstGet: isFirstSync) { result in

                guard let pagedList = try? result.get() else {
                    completionHandler(APIError.emptyResponse)
                    return
                }

                // Notify Listeners
                let isLastPage = pagedList.next == nil
                NotificationCenter.default.post(name: self.syncDownloadStatusUpdateNotification, object: self, userInfo: [
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
