//
//  SyncManager.swift
//  PretixScan
//
//  Created by Daniel Jilg on 08.04.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

// swiftlint:disable statement_position

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

        syncTimer = Timer.scheduledTimer(timeInterval: 1 * 60, target: self, selector: #selector(checkSyncing),
                                         userInfo: nil, repeats: true)

        NotificationCenter.default.addObserver(self, selector: #selector(syncNotification(_:)),
                                               name: SyncManager.syncStatusUpdateNotification, object: nil)
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

    private var dataTaskQueue = [URLSessionDataTask]()

    // MARK: - Syncing
    /// Force a complete redownload of all synced data
    public func forceSync() {
        guard let event = configStore.event else { return }
        configStore.dataStore?.invalidateLastSynced(in: event)
        beginSyncing()
    }

    private var lastSyncTime = Date.distantPast
    private var isSyncing = false

    /// Check if the last sync is longer than 5 minutes ago and if so, trigger a new one.
    @objc
    public func checkSyncing() {
        guard !isSyncing else { return }
        guard -lastSyncTime.timeIntervalSinceNow > 5 * 60 else { return }

        beginSyncing()
    }

    /// Trigger a sync process, which will check for new data from the server
    public func beginSyncing() {
        isSyncing = true
        NotificationCenter.default.post(name: SyncManager.syncBeganNotification, object: nil)
        continueSyncing()
    }

    private func endSyncing() {
        self.lastSyncTime = Date()
        NotificationCenter.default.post(name: SyncManager.syncEndedNotification, object: nil,
                                        userInfo: [SyncManager.NotificationKeys.lastSyncDate: self.lastSyncTime])
        NotificationCenter.default.post(name: SyncManager.syncEndedNotification, object: nil)
        self.isSyncing = false
    }

    private func continueSyncing() {
        guard let dataStore = configStore.dataStore else { return }
        guard let event = configStore.event else { return }

        let firstSyncCompletionHandler: ((Error?) -> Void) = { error in
            if let error = error {
                print(error)
            }

            self.continueSyncing()

            if self.dataTaskQueue.count <= 1 {
                self.endSyncing()
            }
        }

        let laterSyncCompletionHandler: ((Error?) -> Void) = { error in
            if let error = error {
                print(error)
            }

            if self.dataTaskQueue.count <= 1 {
                self.endSyncing()
            }
        }

        // First Sync
        if dataStore.lastSyncTime(of: ItemCategory.self, in: event) == nil {
            // ItemCategory never synced
            queue(task: syncTask(ItemCategory.self, isFirstSync: true, completionHandler: firstSyncCompletionHandler))
        }

        else if dataStore.lastSyncTime(of: Item.self, in: event) == nil {
            // Item never synced
            queue(task: syncTask(Item.self, isFirstSync: true, completionHandler: firstSyncCompletionHandler))
        }

        else if dataStore.lastSyncTime(of: Order.self, in: event) == nil {
            // Orders never synced
            queue(task: syncTask(Order.self, isFirstSync: true, completionHandler: firstSyncCompletionHandler))
        }

        else if dataStore.lastSyncTime(of: Event.self, in: event) == nil {
            // Events never synced
            queue(task: syncTask(Event.self, isFirstSync: true, completionHandler: firstSyncCompletionHandler))
        }

        else if dataStore.lastSyncTime(of: CheckInList.self, in: event) == nil {
            // CheckInLists never synced
            queue(task: syncTask(CheckInList.self, isFirstSync: true, completionHandler: firstSyncCompletionHandler))
        }

        else {
            // TODO: Double check that the correct lastSyncTimes are being stored and used

            // Queue Download Update Tasksh
            queue(task: syncTask(Event.self, isFirstSync: false, completionHandler: laterSyncCompletionHandler))
            queue(task: syncTask(CheckInList.self, isFirstSync: false, completionHandler: laterSyncCompletionHandler))
            queue(task: syncTask(ItemCategory.self, isFirstSync: false, completionHandler: laterSyncCompletionHandler))
            queue(task: syncTask(Item.self, isFirstSync: false, completionHandler: laterSyncCompletionHandler))
            queue(task: syncTask(Order.self, isFirstSync: false, completionHandler: laterSyncCompletionHandler))

            // Queue upload tasks for RedemptionRequests
            uploadQueuedRedemptionRequest(in: event)
        }
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
            let dataStore = try getDataStore()

            return configStore.apiClient?.getTask(model, lastUpdated: dataStore.lastSyncTime(of: model, in: event),
                                                  isFirstGet: isFirstSync) { result in

                guard let pagedList = try? result.get() else {
                    completionHandler(APIError.emptyResponse)
                    return
                }

                // Notify Listeners
                let isLastPage = pagedList.next == nil
                NotificationCenter.default.post(name: SyncManager.syncStatusUpdateNotification, object: self, userInfo: [
                    NotificationKeys.model: model.humanReadableName,
                    NotificationKeys.loadedAmount: pagedList.results.count,
                    NotificationKeys.totalAmount: pagedList.count,
                    NotificationKeys.isLastPage: isLastPage])

                // Store Data
                self.configStore.dataStore?.store(pagedList.results, for: event)

                // Callback that we are completely finished
                if isLastPage {
                    self.configStore.dataStore?.setLastSyncTime(pagedList.generatedAt ?? "", of: model, in: event)
                    completionHandler(nil)
                }
            }
        } catch {
            completionHandler(error)
            return nil
        }
    }
}

// MARK: - Uploading
private extension SyncManager {
    func uploadQueuedRedemptionRequest(in event: Event) {
        if let firstRedemptionRequest = configStore.dataStore?.getRedemptionRequest(in: event) {
            queue(task: configStore.apiClient?.redeemTask(
                secret: firstRedemptionRequest.secret,
                force: firstRedemptionRequest.redemptionRequest.force,
                ignoreUnpaid: firstRedemptionRequest.redemptionRequest.ignoreUnpaid) { (_, error) in
                    if error == nil {
                        // Upload went through
                        self.configStore.dataStore?.delete(firstRedemptionRequest, in: event)
                    }

                    // Begin the next upload
                    self.uploadQueuedRedemptionRequest(in: event)

                    // Notify Queue Management
                    let totalAmount = self.configStore.dataStore?.numberOfRedemptionRequestsInQueue(in: event) ?? 0
                    NotificationCenter.default.post(name: SyncManager.syncStatusUpdateNotification, object: self, userInfo: [
                        NotificationKeys.model: QueuedRedemptionRequest.humanReadableName,
                        NotificationKeys.loadedAmount: 1,
                        NotificationKeys.totalAmount: totalAmount,
                        NotificationKeys.isLastPage: (totalAmount <= 1)])
                }
            )
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

    func getDataStore() throws -> DataStore {
        guard let dataStore = configStore.dataStore else {
            throw APIError.notConfigured(message: "ConfigStore.dataStore property must be set before calling this function.")
        }

        return dataStore
    }
}
