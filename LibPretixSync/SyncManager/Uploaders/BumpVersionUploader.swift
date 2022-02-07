//
//  BumpVersionUploader.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 07/02/2022.
//  Copyright © 2022 rami.io. All rights reserved.
//

import Foundation

final class BumpVersionUploader: APIClientOperation {
    var shouldRepeat = true
    
    override func start() {
        if isCancelled {
            completeOperation()
        }
        
        isExecuting = true
        let pxd = PXDeviceInitialization(UserDefaults.standard)
        if !pxd.needsToUpdate() {
            logger.debug("No need to bump device version")
            self.shouldRepeat = true
            self.completeOperation()
            return
        }
        
        guard let request = pxd.getUpdateRequest() else {
            logger.error("BumpVersionUploader received an empty device update request")
            self.shouldRepeat = true
            self.completeOperation()
            return
        }
        
        urlSessionTask = apiClient.update(request) { error in
            if error == nil {
                DispatchQueue.main.async {
                    pxd.setPublishedVersion(request.softwareVersion)
                }
            }
            // The instantiator of this class should queue more operations in the completion block.
            self.shouldRepeat = true
            self.completeOperation()
        }
        urlSessionTask?.resume()
    }
}
