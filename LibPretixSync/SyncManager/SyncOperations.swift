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

    init(apiClient: APIClient, event: Event, checkInList: CheckInList) {
        self.apiClient = apiClient
        self.event = event
        self.checkInList = checkInList
    }

    // MARK: - Management Methods
    override func start() {
        if isCancelled {
            return
        }

        isExecuting = true

        // TODO: Do actual work
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

class FullOrderDownloader: APIClientOperation {
    override func start() {
        print("DownloadAllOrders start")
        if isCancelled {
            return
        }

        isExecuting = true

        // TODO: Check if full order sync already happened

        let task = apiClient.getTask(Order.self, lastUpdated: nil, isFirstGet: true) { result in
            guard let pagedList = try? result.get() else {
                // TODO: completionHandler(APIError.emptyResponse)
                // TODO: Report error somewhere
                self.completeOperation()
                return
            }

            // Notify Listeners

            print("DownloadAllOrders checkIn")
            let isLastPage = pagedList.next == nil
            //NotificationCenter.default.post(name: SyncManager.syncStatusUpdateNotification, object: self, userInfo: [
            //    NotificationKeys.model: model.humanReadableName,
            //    NotificationKeys.loadedAmount: pagedList.results.count,
            //    NotificationKeys.totalAmount: pagedList.count,
            //    NotificationKeys.isLastPage: isLastPage])

            // Store Data
            // TODO: self.configStore.dataStore?.store(pagedList.results, for: event)

            // Callback that we are completely finished
            if isLastPage {
                // TODO: self.configStore.dataStore?.setLastSyncTime(pagedList.generatedAt ?? "", of: model, in: event)
                self.completeOperation()

                print("DownloadAllOrders complete")
            }
        }
        task?.resume()
    }
}
