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
    
    weak var configStore: ConfigStore?
    
    override func start() {
        if isCancelled {
            completeOperation()
        }
        
        isExecuting = true
        
        guard let configStore = configStore else {
            logger.error("BumpVersionUploader requires a configStore instance but got nil")
            self.shouldRepeat = true
            self.completeOperation()
            return
        }
        
        let pxd = PXDeviceInitialization(configStore)
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
            if let error = error {
                logger.error("🍅 BumpVersionUploader failed \(String(describing: error))")
            } else {
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
