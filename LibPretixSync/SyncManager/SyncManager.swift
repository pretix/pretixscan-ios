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
    private var syncTimer: Timer?

    init(configStore: ConfigStore) {
        self.configStore = configStore
    }

    // MARK: - Notifications
    public static var syncBeganNotification: Notification.Name { return Notification.Name("SyncManagerSyncBegan") }
    public static var syncStatusUpdateNotification: Notification.Name { return Notification.Name("SyncManagerSyncStatusUpdate") }
    public static var syncEndedNotification: Notification.Name { return Notification.Name("SyncManagerSyncEnded") }

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

        /// Sent in the syncingEnded notification, the last Date when the sync finished
        case lastSyncDate
    }

    // MARK: - Syncing
    /// Force a complete redownload of all synced data
    public func forceSync() {
        guard let event = configStore.event,
            let checkInList = configStore.checkInList,
            let apiClient = configStore.apiClient,
            let dataStore = configStore.dataStore else {
                print("SyncStore will not work unless event, checkinList, dataStore and APIclient are set")
                return
        }

        populateQueues(apiClient: apiClient, dataStore: dataStore, event: event, checkInList: checkInList)
    }

    /// Trigger a sync process, which will check for new data from the server
    public func beginSyncing() {
        guard let event = configStore.event,
            let checkInList = configStore.checkInList,
            let apiClient = configStore.apiClient,
            let dataStore = configStore.dataStore else {
            print("SyncStore will not work unless event, checkinList, dataStore and APIclient are set")
            return
        }

        populateQueues(apiClient: apiClient, dataStore: dataStore, event: event, checkInList: checkInList)
    }

    // MARK: - Queues
    private lazy var downloadsInProgress: [String: Operation] = [:]
    private lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download Queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    private lazy var uploadsInProgress: [String: Operation] = [:]
    private lazy var uploadQeuue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Upload Queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    private func populateQueues(apiClient: APIClient, dataStore: DataStore, event: Event, checkInList: CheckInList) {
        populateDownloadQueue(apiClient: apiClient, dataStore: dataStore, event: event, checkInList: checkInList)
        populateUploadQueue(apiClient: apiClient, dataStore: dataStore, event: event, checkInList: checkInList)
    }

    private func populateDownloadQueue(apiClient: APIClient, dataStore: DataStore, event: Event, checkInList: CheckInList) {
        if downloadsInProgress[ItemCategory.stringName] == nil {
            let downloader = ItemCategoriesDownloader(apiClient: apiClient, dataStore: dataStore, event: event, checkInList: checkInList)
            downloader.completionBlock = {
                if downloader.isCancelled { return }
                if let error = downloader.error { print(error) }
                DispatchQueue.main.async {
                    self.downloadsInProgress.removeValue(forKey: downloader.model.stringName)
                }
            }

            downloadsInProgress[downloader.model.stringName] = downloader
            downloadQueue.addOperation(downloader)
        }

        if downloadsInProgress[Item.stringName] == nil {
            let downloader = ItemsDownloader(apiClient: apiClient, dataStore: dataStore, event: event, checkInList: checkInList)
            downloader.completionBlock = {
                if downloader.isCancelled { return }
                if let error = downloader.error { print(error) }
                DispatchQueue.main.async {
                    self.downloadsInProgress.removeValue(forKey: downloader.model.stringName)
                }
            }

            downloadsInProgress[downloader.model.stringName] = downloader
            downloadQueue.addOperation(downloader)
        }

        if downloadsInProgress[SubEvent.stringName] == nil {
            let downloader = SubEventsDownloader(apiClient: apiClient, dataStore: dataStore, event: event, checkInList: checkInList)
            downloader.completionBlock = {
                if downloader.isCancelled { return }
                if let error = downloader.error { print(error) }
                DispatchQueue.main.async {
                    self.downloadsInProgress.removeValue(forKey: downloader.model.stringName)
                }
            }

            downloadsInProgress[downloader.model.stringName] = downloader
            downloadQueue.addOperation(downloader)
        }

        let fullOrderKey = Order.stringName + "-full"
        if downloadsInProgress[fullOrderKey] == nil {
            let downloader = FullOrderDownloader(apiClient: apiClient, dataStore: dataStore, event: event, checkInList: checkInList)
            downloader.completionBlock = {
                if downloader.isCancelled { return }
                if let error = downloader.error { print(error) }
                DispatchQueue.main.async {
                    self.downloadsInProgress.removeValue(forKey: fullOrderKey)
                }
            }

            downloadsInProgress[fullOrderKey] = downloader
            downloadQueue.addOperation(downloader)
        }

        if downloadsInProgress[Order.stringName] == nil {
            let downloader = PartialOrderDownloader(apiClient: apiClient, dataStore: dataStore, event: event, checkInList: checkInList)
            downloader.completionBlock = {
                if downloader.isCancelled { return }
                if let error = downloader.error { print(error) }
                DispatchQueue.main.async {
                    self.downloadsInProgress.removeValue(forKey: fullOrderKey)
                }
            }

            downloadsInProgress[Order.stringName] = downloader
            downloadQueue.addOperation(downloader)
        }

    }

    private func populateUploadQueue(apiClient: APIClient, dataStore: DataStore, event: Event, checkInList: CheckInList) {
        
    }
}
