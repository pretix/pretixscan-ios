//
//  QueuedRedemptionRequestsUploader.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 30/09/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation


final class QueuedRedemptionRequestsUploader: APIClientOperation {
    var errorReason: RedemptionResponse.ErrorReason?
    var shouldRepeat = true
    
    override func start() {
        if isCancelled {
            completeOperation()
        }
        
        isExecuting = true
        
        guard let nextQueuedRedemptionRequest = dataStore.getRedemptionRequest() else {
            // No more queued redemption requests, so we don't need to do anything, and not add more uploads to the queue
            self.shouldRepeat = false
            self.completeOperation()
            return
        }
        
        Task {
            var request = nextQueuedRedemptionRequest
            if let answers = request.redemptionRequest.answers {
                request.redemptionRequest.answers = await apiClient.uploadAttachments(answers: answers)
                
            }
            
            
            urlSessionTask = apiClient.redeemTask(
                secret: request.secret,
                redemptionRequest: request.redemptionRequest,
                eventSlug: request.eventSlug,
                checkInListIdentifier: request.checkInListIdentifier
            ) { result, error in
                // Handle HTTP errors
                // When HTTP errors occur, we do not want to remove the queued redemption request, since it probably didn't reach the server
                if let error = error {
                    self.error = error
                    
                    if let apiError = error as? APIError {
                        switch apiError {
                        case .forbidden, .notFound:
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
                
                // Response Errors
                // Response errors mean the server has received our request correctly and has declined it for some reason
                // (e.g. already checked in). In that case, we can't do anything, because the check in happened in the past.
                self.errorReason = result?.errorReason
                
                // Done, delete the queued redemption request
                self.dataStore.delete(nextQueuedRedemptionRequest)
                
                // The instantiator of this class should queue more operations in the completion block.
                self.shouldRepeat = true
                self.completeOperation()
            }
            urlSessionTask?.resume()
        }
    }
}
