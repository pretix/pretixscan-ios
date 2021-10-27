//
//  EventValidKeysDownloader.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 27/10/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation

/// Downloads and stores the valid signing keys for the event.
class EventValidKeysDownloader: APIClientOperation {
    
    override func start() {
        if isCancelled {
            completeOperation()
            return
        }

        isExecuting = true
        urlSessionTask = apiClient.getEventDetailTask(self.event.slug) { result in
            switch result {
            case .success(let eventDetail):
                let validKeys = (eventDetail.validKeys?.pems ?? []).map({EventValidKey(key: $0)})
                self.dataStore.store(validKeys, for: eventDetail)
                self.completeOperation()
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
}
