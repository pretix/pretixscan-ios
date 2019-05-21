//
//  SyncOperations.swift
//  PretixScan
//
//  Created by Daniel Jilg on 04.05.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

class APIClientOperation: Operation {
    // MARK: - Public Properties
    let apiClient: APIClient
    let event: Event
    let checkInList: CheckInList
    let dataStore: DataStore

    /// If not nil, the error that occurred during fetch
    var error: Error?

    // MARK: - Private Properties
    private var urSessionTask: URLSessionTask?

    // MARK: - KVO Property Management
    private var _executing = false
    private var _finished = false

    override var isAsynchronous: Bool { return true }

    override var isExecuting: Bool {
        get {
            return _executing
        } set {
            willChangeValue(forKey: "isExecuting")
            _executing = newValue
            didChangeValue(forKey: "isExecuting")
        }
    }

    override var isFinished: Bool {
        get {
            return _finished
        } set {
            willChangeValue(forKey: "isFinished")
            _finished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }

    init(apiClient: APIClient, dataStore: DataStore, event: Event, checkInList: CheckInList) {
        self.apiClient = apiClient
        self.event = event
        self.checkInList = checkInList
        self.dataStore = dataStore
    }

    // MARK: - Management Methods
    override func start() {
        if isCancelled {
            return
        }

        isExecuting = true

        // Override this method to do actual work

        completeOperation()
    }

    func completeOperation() {
        isFinished = true
        isExecuting = false
    }

    override func cancel() {
        super.cancel()
        if isExecuting {
            isFinished = true
            isExecuting = false
        }

        urSessionTask?.cancel()
    }
}

class FullDownloader<T: Model>: APIClientOperation {
    override func start() {
        if isCancelled {
            completeOperation()
        }

        isExecuting = true

        if dataStore.lastSyncTime(of: T.self, in: event) != nil {
            // full sync already happened, we don't need to do anything
            completeOperation()
        }

        let task = apiClient.getTask(T.self, lastUpdated: nil) { result in
            switch result {
            case .success(let pagedList):
                let isLastPage = pagedList.next == nil

                // Notify Listeners
                NotificationCenter.default.post(name: SyncManager.syncStatusUpdateNotification, object: self, userInfo: [
                    SyncManager.NotificationKeys.model: T.self.humanReadableName,
                    SyncManager.NotificationKeys.loadedAmount: pagedList.results.count,
                    SyncManager.NotificationKeys.totalAmount: pagedList.count,
                    SyncManager.NotificationKeys.isLastPage: isLastPage])

                // Store Data
                self.dataStore.store(pagedList.results, for: self.event)

                if isLastPage {
                    // We are done
                    self.dataStore.setLastSyncTime(pagedList.generatedAt ?? "", of: T.self, in: self.event)
                    self.completeOperation()
                }
            case .failure(let error):
                self.error = error
                self.completeOperation()
            }

        }
        task?.resume()
    }
}

class PartialDownloader<T: Model>: APIClientOperation {
    override func start() {
        if isCancelled {
            completeOperation()
        }

        isExecuting = true
        let lastUpdated = dataStore.lastSyncTime(of: T.self, in: event)

        let task = apiClient.getTask(T.self, lastUpdated: lastUpdated) { result in
            switch result {
            case .success(let pagedList):
                let isLastPage = pagedList.next == nil

                // Notify Listeners
                NotificationCenter.default.post(name: SyncManager.syncStatusUpdateNotification, object: self, userInfo: [
                    SyncManager.NotificationKeys.model: T.self.humanReadableName,
                    SyncManager.NotificationKeys.loadedAmount: pagedList.results.count,
                    SyncManager.NotificationKeys.totalAmount: pagedList.count,
                    SyncManager.NotificationKeys.isLastPage: isLastPage])

                // Store Data
                self.dataStore.store(pagedList.results, for: self.event)

                if isLastPage {
                    // We are done
                    self.dataStore.setLastSyncTime(pagedList.generatedAt ?? "", of: T.self, in: self.event)
                    self.completeOperation()
                }
            case .failure(let error):
                self.error = error
                self.completeOperation()
            }

        }
        task?.resume()
    }
}

class ItemCategoriesDownloader: FullDownloader<ItemCategory> {
    let model = ItemCategory.self
}

class ItemsDownloader: FullDownloader<Item> {
    let model = Item.self
}

class FullOrderDownloader: FullDownloader<Order> {
    let model = Order.self
}

class PartialOrderDownloader: PartialDownloader<Order> {
    let model = Order.self
}

class SubEventsDownloader: FullDownloader<SubEvent> {
    let model = SubEvent.self
}
