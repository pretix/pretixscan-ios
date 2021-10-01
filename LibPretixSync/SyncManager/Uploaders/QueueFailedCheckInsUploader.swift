//
//  QueueFailedCheckInsUploader.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 30/09/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation

final class QueueFailedCheckInsUploader: APIClientOperation {
    var shouldRepeat = true
    
    override func start() {
        if isCancelled {
            completeOperation()
        }
        
        isExecuting = true
        
        let dbRecord = dataStore.getFailedCheckIn()
        guard let rowId = dbRecord.0, let nextItem = dbRecord.1 else {
            self.shouldRepeat = false
            self.completeOperation()
            return
        }
        
        urlSessionTask = apiClient.failedCheckInTask(nextItem) { error in
            // Handle HTTP errors
            // When HTTP errors occur, we do not want to remove the queued redemption request, since it probably didn't reach the server
            if let error = error {
                self.error = error
                
                if let apiError = error as? APIError {
                    switch apiError {
                    case .notFound:
                        // Probably running outdated server where this feature is not available.
                        self.error = nil
                        self.shouldRepeat = false
                        self.completeOperation()
                        return
                    case .forbidden:
                        // This is probably a malformed request and will never go through.
                        // Continue on and let the queued request be deleted.
                        break
                    case .retryAfter(_):
                        // The server has responsed with HTTP 429 requesting that we retry again later.
                        // We should delay further processing with the requested time interval.
                        self.shouldRepeat = true
                        self.completeOperation()
                        return
                    default:
                        self.completeOperation()
                        return
                    }
                } else {
                    self.completeOperation()
                    return
                }
            }
            
            
            // Done, delete the queued redemption request
            self.dataStore.delete(failedCheckInRowId: rowId)
            
            // The instantiator of this class should queue more operations in the completion block.
            self.shouldRepeat = true
            self.completeOperation()
        }
        urlSessionTask?.resume()
    }
}
