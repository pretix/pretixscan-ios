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
    private let timeBetweenSyncs: TimeInterval = 5 * 60
    private var lastRequestedSync: Date? = nil
    
    init(configStore: ConfigStore) {
        self.configStore = configStore
    }
    
    // MARK: - Notifications
    /// Notification being sent out once a sync process has started
    public static var syncBeganNotification: Notification.Name { return Notification.Name("SyncManagerSyncBegan") }
    
    /// Notification being sent out every time the status of the sync process updates.
    ///
    /// @see `NotificationKeys` for the attached dictionary.
    public static var syncStatusUpdateNotification: Notification.Name { return Notification.Name("SyncManagerSyncStatusUpdate") }
    
    /// Notification being sent out once a sync process has ended
    public static var syncEndedNotification: Notification.Name { return Notification.Name("SyncManagerSyncEnded") }
    
    /// Notification being sent out every time the status of a queued upload process changes.
    public static var uploadStatusNotification: Notification.Name { return Notification.Name("SyncManagerUploadStatus") }
    
    /// Notification being sent out if the sync status is reset
    ///
    /// DataStore implementations are responsible for sending this notification
    public static var syncStatusResetNotification: Notification.Name { return Notification.Name("SyncManagerSyncReset") }
    
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
                  assertionFailure("event, checkinList, dataStore and APIclient should be set")
                  EventLogger.log(event: "forseSync: SyncStore will not work unless event, checkinList, dataStore and APIclient are set",
                                  category: .configuration, level: .warning, type: .default)
                  return
              }
        
        configStore.dataStore?.destroyDataStore(for: event, recreate: true)
        populateQueues(apiClient: apiClient, dataStore: dataStore, event: event, checkInList: checkInList)
    }
    
    /// Trigger a sync process, which will check for new data from the server, but only if auto sync is enabled. This method respects the `timeBetweenSyncs`.
    public func beginSyncingIfAutoSync() {
        if configStore.shouldAutoSync {
            if let lastRequestedSync = lastRequestedSync {
                if Date() - lastRequestedSync < timeBetweenSyncs {
                    // ignoring request to sync before timeBetweenSyncs has elapsed
                    return
                }
            }
            beginSyncing()
        }
    }
    
    /// Trigger a sync process, which will check for new data from the server
    @objc public func beginSyncing() {
        guard let event = configStore.event,
              let checkInList = configStore.checkInList,
              let apiClient = configStore.apiClient,
              let dataStore = configStore.dataStore else {
                  assertionFailure("event, checkinList, dataStore and APIclient should be set")
                  EventLogger.log(event: "beginSyncing: SyncStore will not work unless event, checkinList, dataStore and APIclient are set",
                                  category: .configuration, level: .warning, type: .default)
                  return
              }
        
        populateQueues(apiClient: apiClient, dataStore: dataStore, event: event, checkInList: checkInList)
    }
    
    // MARK: - Queues
    private lazy var queue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download Queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    private func populateQueues(apiClient: APIClient, dataStore: DataStore, event: Event, checkInList: CheckInList) {
        populateUploadQueue(apiClient: apiClient, dataStore: dataStore, event: event, checkInList: checkInList)
    }
    
    private func populateDownloadQueue(apiClient: APIClient, dataStore: DataStore, event: Event, checkInList: CheckInList) {
        let events = EventsDownloader(apiClient: apiClient, dataStore: dataStore, event: event, checkInList: checkInList)
        events.configStore = configStore
        let revokedSecrets = RevokedSecretDownloader(apiClient: apiClient, dataStore: dataStore, event: event, checkInList: checkInList)
        revokedSecrets.addDependency(events)
        
        let validKeys = EventValidKeysDownloader(apiClient: apiClient, dataStore: dataStore, event: event, checkInList: checkInList)
        validKeys.addDependency(events)
        
        let checkInLists = CheckInListsDownloader(apiClient: apiClient, dataStore: dataStore, event: event, checkInList: checkInList)
        checkInLists.configStore = configStore
        
        let itemCategories = ItemCategoriesDownloader(apiClient: apiClient, dataStore: dataStore, event: event, checkInList: checkInList)
        let items = ItemsDownloader(apiClient: apiClient, dataStore: dataStore, event: event, checkInList: checkInList)
        let subEvents = SubEventsDownloader(apiClient: apiClient, dataStore: dataStore, event: event, checkInList: checkInList)
        let questions = QuestionsDownloader(apiClient: apiClient, dataStore: dataStore, event: event, checkInList: checkInList)
        
        var allSyncOperations = [events, revokedSecrets, validKeys, checkInLists, itemCategories, items, subEvents, questions]
        
        if configStore.shouldDownloadOrders {
            let fullOrders = FullOrderDownloader(apiClient: apiClient, dataStore: dataStore, event: event,
                                                 checkInList: checkInList, disableTestMode: true)
            let partialOrders = PartialOrderDownloader(apiClient: apiClient, dataStore: dataStore, event: event,
                                                       checkInList: checkInList, disableTestMode: true)
            partialOrders.addDependency(fullOrders)
            
            allSyncOperations.append(contentsOf: [fullOrders, partialOrders])
        }
        
        allSyncOperations.forEach { queue.addOperation($0) }
        
        // Cleanup
        let cleanUpOperation = BlockOperation {
            // Send out a Notification Raven to inform every one
            let moment = Date()
            NotificationCenter.default.post(
                name: SyncManager.syncEndedNotification,
                object: self,
                userInfo: [SyncManager.NotificationKeys.lastSyncDate: Date()])
            
            DispatchQueue.main.async {[weak self] in
                self?.lastRequestedSync = moment
            }
            
            // Queue in the next Sync
            if self.configStore.shouldAutoSync {
                DispatchQueue.main.asyncAfter(deadline: .now() + self.timeBetweenSyncs) {
                    self.beginSyncingIfAutoSync()
                }
            }
        }
        // Cleanup should only happen once all other operations are finished
        allSyncOperations.forEach { cleanUpOperation.addDependency($0) }
        
        queue.addOperation(cleanUpOperation)
    }
    
    private func createQueuedRedemptionRequestsUploader(apiClient: APIClient, dataStore: DataStore, event: Event, checkInList: CheckInList) -> QueuedRedemptionRequestsUploader {
        let uploader = QueuedRedemptionRequestsUploader(apiClient: apiClient, dataStore: dataStore, event: event, checkInList: checkInList)
        uploader.completionBlock = {[weak self] in
            if case .retryAfter(let seconds) = uploader.error as? APIError, uploader.shouldRepeat {
                print("Queued Redemption Request Received Retry-After \(seconds) seconds header. Postponing upload.")
                self?.populateUploadQueue(apiClient: apiClient, dataStore: dataStore, event: event, checkInList: checkInList, delay: TimeInterval(seconds))
                return
            }
            if let error = uploader.error {
                if let urlError = error as? URLError, urlError.code == URLError.Code.notConnectedToInternet {
                    logger.debug("Queued Redemption Request failed while not connected to internet.")
                } else {
                    EventLogger.log(event: "Queued Redemption Request came back with error: \(error)",
                                    category: .offlineUpload, level: .error, type: .error)
                }
            }
            if let errorReason = uploader.errorReason {
                // If error reason is set, we are not dealing with a system error;
                // instead, the server has responded that this ticket should not be redeemed.
                // Therefore, do not log the error and spam Sentry, just print it out for debug.
                print("Queued Redemption Request came back with errorReason: \(errorReason)")
            }
            
            if uploader.shouldRepeat {
                self?.populateUploadQueue(apiClient: apiClient, dataStore: dataStore, event: event, checkInList: checkInList)
            } else if (uploader.error == nil) {
                self?.populateFailedCheckInQueue(apiClient: apiClient, dataStore: dataStore, event: event, checkInList: checkInList)
            }
        }
        return uploader
    }
    
    private func createBumpVersionUploader(apiClient: APIClient, dataStore: DataStore, event: Event, checkInList: CheckInList) -> BumpVersionUploader {
        let uploader = BumpVersionUploader(apiClient: apiClient, dataStore: dataStore, event: event, checkInList: checkInList)
        uploader.completionBlock = {[weak self] in
            if case .retryAfter(let seconds) = uploader.error as? APIError, uploader.shouldRepeat {
                print("BumpVersionUploader Request Received Retry-After \(seconds) seconds header. Postponing upload.")
                self?.populateUploadQueue(apiClient: apiClient, dataStore: dataStore, event: event, checkInList: checkInList, delay: TimeInterval(seconds))
                return
            }
            if let error = uploader.error {
                if let urlError = error as? URLError, urlError.code == URLError.Code.notConnectedToInternet {
                    logger.debug("BumpVersionUploader Request failed while not connected to internet.")
                } else {
                    EventLogger.log(event: "BumpVersionUploader Request came back with error: \(error)",
                                    category: .offlineUpload, level: .error, type: .error)
                }
            }
        }
        return uploader
    }
    
    private func createFailedCheckInsUploader(apiClient: APIClient, dataStore: DataStore, event: Event, checkInList: CheckInList) -> QueueFailedCheckInsUploader {
        let uploader = QueueFailedCheckInsUploader(apiClient: apiClient, dataStore: dataStore, event: event, checkInList: checkInList)
        uploader.completionBlock = {[weak self] in
            if case .retryAfter(let seconds) = uploader.error as? APIError, uploader.shouldRepeat {
                print("Queued Redemption Request Received Retry-After \(seconds) seconds header. Postponing upload.")
                self?.populateUploadQueue(apiClient: apiClient, dataStore: dataStore, event: event, checkInList: checkInList, delay: TimeInterval(seconds))
                return
            }
            if let error = uploader.error {
                if let urlError = error as? URLError, urlError.code == URLError.Code.notConnectedToInternet {
                    logger.debug("Queued Redemption Request failed while not connected to internet.")
                } else {
                    EventLogger.log(event: "Queued Failed Check-In came back with error: \(error)",
                                    category: .offlineUpload, level: .error, type: .error)
                }
            }
         
            if uploader.shouldRepeat {
                self?.populateFailedCheckInQueue(apiClient: apiClient, dataStore: dataStore, event: event, checkInList: checkInList)
            } else if (uploader.error == nil) {
                self?.populateDownloadQueue(apiClient: apiClient, dataStore: dataStore, event: event, checkInList: checkInList)
            }
        }
        return uploader
    }
    
    private func populateFailedCheckInQueue(apiClient: APIClient, dataStore: DataStore, event: Event, checkInList: CheckInList) {
        let uploader = createFailedCheckInsUploader(apiClient: apiClient, dataStore: dataStore, event: event, checkInList: checkInList)
        queue.addOperation(uploader)
    }
    
    private func populateUploadQueue(apiClient: APIClient, dataStore: DataStore, event: Event, checkInList: CheckInList) {
        let updateVersion = createBumpVersionUploader(apiClient: apiClient, dataStore: dataStore, event: event, checkInList: checkInList)
        queue.addOperation(updateVersion)
        let uploader = createQueuedRedemptionRequestsUploader(apiClient: apiClient, dataStore: dataStore, event: event, checkInList: checkInList)
        queue.addOperation(uploader)
    }
    
    private func populateUploadQueue(apiClient: APIClient, dataStore: DataStore, event: Event, checkInList: CheckInList, delay: TimeInterval) {
        let delay = DelayedBlockOperation(delay: delay)
        let uploader = createQueuedRedemptionRequestsUploader(apiClient: apiClient, dataStore: dataStore, event: event, checkInList: checkInList)
        uploader.addDependency(delay)
        queue.addOperation(delay)
        queue.addOperation(uploader)
    }
}
