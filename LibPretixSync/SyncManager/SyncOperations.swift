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
    let disableTestMode: Bool

    /// If not nil, the error that occurred during fetch
    var error: Error?

    // MARK: - Private Properties
    var urlSessionTask: URLSessionTask?

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

    init(apiClient: APIClient, dataStore: DataStore, event: Event, checkInList: CheckInList, disableTestMode: Bool = false) {
        self.apiClient = apiClient
        self.event = event
        self.checkInList = checkInList
        self.dataStore = dataStore
        self.disableTestMode = disableTestMode
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

        urlSessionTask?.cancel()
    }
}

class FullDownloader<T: Model>: APIClientOperation {
    override func start() {
        if isCancelled {
            completeOperation()
            return
        }

        isExecuting = true

        var filters = [String: String]()

        if disableTestMode {
            filters["testmode"] = "false"
        }

        let lastSyncCreationTime = dataStore.lastSyncCreationTime(of: T.self, in: event)
        if (lastSyncCreationTime == "complete") {
            if (dataStore.lastSyncTime(of: T.self, in: event) != nil) {
                completeOperation()
                return
            }
        } else if lastSyncCreationTime != nil {
            filters["created_since"] = lastSyncCreationTime
        }

        urlSessionTask = apiClient.getTask(T.self, page: 1, lastUpdated: nil, event: event, filters: filters) { result in
            switch result {
            case .success(let pagedList):
                let isLastPage = pagedList.next == nil
                let isFirstPage = pagedList.previous == nil

                // Notify Listeners
                NotificationCenter.default.post(name: SyncManager.syncStatusUpdateNotification, object: self, userInfo: [
                    SyncManager.NotificationKeys.model: T.self.humanReadableName,
                    SyncManager.NotificationKeys.loadedAmount: pagedList.results.count,
                    SyncManager.NotificationKeys.totalAmount: pagedList.count,
                    SyncManager.NotificationKeys.isLastPage: isLastPage])

                // Handle Data
                self.handle(data: pagedList.results)

                if let pagedList = pagedList as? PagedList<Order>, let creationTimeOfLastObject = pagedList.results.last?.createdAt {
                    // Special case for Full Downloading Order objects: Save the creation time, to use for partial syncs
                    self.dataStore.setLastSyncCreatedTime(creationTimeOfLastObject, of: T.self, in: self.event)
                }

                if isFirstPage, let generatedAt = pagedList.generatedAt {
                    self.dataStore.setLastSyncModifiedTime(generatedAt, of: T.self, in: self.event)
                }

                if isLastPage {
                    if pagedList as? PagedList<Order> != nil {
                        self.dataStore.setLastSyncCreatedTime("complete", of: T.self, in: self.event)
                    }
                    self.completeOperation()
                }
            case .failure(let error):
                switch (error as? APIError) {
                case .unchanged:
                    break
                default:
                    self.error = error
                }
                self.completeOperation()
            }

        }
        urlSessionTask?.resume()
    }

    /// Deal with the generated data. You can override this in subclasses.
    func handle(data: [T]) {
        self.dataStore.store(data, for: self.event)
    }
}

class PartialDownloader<T: Model>: APIClientOperation {
    override func start() {
        if isCancelled {
            completeOperation()
            return
        }

        isExecuting = true

        let lastUpdated = dataStore.lastSyncTime(of: T.self, in: event)

        var firstPageGeneratedAt: String?

        var filters = [String: String]()
        if disableTestMode {
            filters["testmode"] = "false"
        }

        urlSessionTask = apiClient.getTask(T.self, lastUpdated: lastUpdated, filters: filters) { result in
            switch result {
            case .success(let pagedList):
                let isLastPage = pagedList.next == nil
                let isFirstPage = pagedList.previous == nil

                // Notify Listeners
                NotificationCenter.default.post(name: SyncManager.syncStatusUpdateNotification, object: self, userInfo: [
                    SyncManager.NotificationKeys.model: T.self.humanReadableName,
                    SyncManager.NotificationKeys.loadedAmount: pagedList.results.count,
                    SyncManager.NotificationKeys.totalAmount: pagedList.count,
                    SyncManager.NotificationKeys.isLastPage: isLastPage])

                // Store Data
                self.dataStore.store(pagedList.results, for: self.event)

                if isFirstPage, let generatedAt = pagedList.generatedAt {
                    firstPageGeneratedAt = generatedAt
                }

                if isLastPage {
                    if let firstPageGeneratedAt = firstPageGeneratedAt {
                        self.dataStore.setLastSyncModifiedTime(firstPageGeneratedAt, of: T.self, in: self.event)
                    }

                    self.completeOperation()
                }
            case .failure(let error):
                self.error = error
                self.completeOperation()
            }

        }
        urlSessionTask?.resume()
    }
}

class ConditionalDownloader<T: Model>: APIClientOperation {
    private var lastModified: String?
    
    override func start() {
        if isCancelled {
            completeOperation()
            return
        }

        isExecuting = true

        var filters = [String: String]()

        if disableTestMode {
            filters["testmode"] = "false"
        }
        
        let ifModifiedSince = dataStore.lastSyncTime(of: T.self, in: event)

        urlSessionTask = apiClient.getTask(T.self, page: 1, lastUpdated: nil, event: event, filters: filters, ifModifiedSince: ifModifiedSince) { result in
            switch result {
            case .success(let pagedList):
                let isLastPage = pagedList.next == nil
                let isFirstPage = pagedList.previous == nil

                // Notify Listeners
                NotificationCenter.default.post(name: SyncManager.syncStatusUpdateNotification, object: self, userInfo: [
                    SyncManager.NotificationKeys.model: T.self.humanReadableName,
                    SyncManager.NotificationKeys.loadedAmount: pagedList.results.count,
                    SyncManager.NotificationKeys.totalAmount: pagedList.count,
                    SyncManager.NotificationKeys.isLastPage: isLastPage])

                // Handle Data
                self.handle(data: pagedList.results)

                if isFirstPage, let lastModified = pagedList.lastModified {
                    self.lastModified = lastModified
                }

                if isLastPage {
                    if self.lastModified != nil {
                        self.dataStore.setLastSyncModifiedTime(self.lastModified!, of: T.self, in: self.event)
                    }
                    self.completeOperation()
                }
            case .failure(let error):
                self.error = error
                self.completeOperation()
            }

        }
        urlSessionTask?.resume()
    }

    /// Deal with the generated data. You can override this in subclasses.
    func handle(data: [T]) {
        self.dataStore.store(data, for: self.event)
    }
}

class ItemCategoriesDownloader: ConditionalDownloader<ItemCategory> {
    let model = ItemCategory.self
}

class ItemsDownloader: ConditionalDownloader<Item> {
    let model = Item.self
}

class FullOrderDownloader: FullDownloader<Order> {
    let model = Order.self
}

class PartialOrderDownloader: PartialDownloader<Order> {
    let model = Order.self
}

class RevokedSecretDownloader: FullDownloader<RevokedSecret> {
    let model = RevokedSecret.self
}

class SubEventsDownloader: ConditionalDownloader<SubEvent> {
    let model = SubEvent.self
}

class EventsDownloader: FullDownloader<Event> {
    let model = Event.self
    var configStore: ConfigStore?

    override func handle(data: [Event]) {
        guard let currentEvent = configStore?.event, let currentCheckInList = configStore?.checkInList else { return }
        for event in data where event == currentEvent {
            configStore?.set(event: event, checkInList: currentCheckInList)
        }
    }
}

class CheckInListsDownloader: ConditionalDownloader<CheckInList> {
    let model = CheckInList.self
    var configStore: ConfigStore?

    override func handle(data: [CheckInList]) {
        guard let currentEvent = configStore?.event, let currentCheckInList = configStore?.checkInList else { return }
        for checkInList in data where checkInList == currentCheckInList {
            configStore?.set(event: currentEvent, checkInList: checkInList)
        }
    }
}

class QuestionsDownloader: ConditionalDownloader<Question> {
    let model = Question.self
}

