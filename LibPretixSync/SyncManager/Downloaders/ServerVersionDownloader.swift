//
//  ServerVersionDownloader.swift
//  pretixSCAN
//
//  Created by Konstantin on 29/03/2023.
//  Copyright © 2023 rami.io. All rights reserved.
//

import Foundation

/// Requests and stores the server version
final class ServerVersionDownloader: APIClientOperation {
    var shouldRepeat = true
    
    weak var configStore: ConfigStore?
    
    override func start() {
        if isCancelled {
            completeOperation()
        }
        
        isExecuting = true
        
        guard let configStore = configStore else {
            logger.error("ServerVersionDownloader requires a configStore instance but got nil")
            self.shouldRepeat = true
            self.completeOperation()
            return
        }
        
        
        urlSessionTask = apiClient.getServerVersion { error, deviceInfo in
            if let error = error {
                logger.error("🍅 ServerVersionDownloader failed \(String(describing: error))")
            } else {
                let version = deviceInfo?.server?.version?.pretixNumeric
                let gate = deviceInfo?.device?.gate?.id
                let gateName = deviceInfo?.device?.gate?.name
                logger.debug("🪧 Server version: \(String(describing: version)), Gate: \(String(describing: gate)) \(String(describing: gateName))")
                DispatchQueue.main.async {
                    configStore.knownPretixVersion = version
                    configStore.deviceKnownGateId = gate
                    configStore.deviceKnownGateName = gateName
                }
            }
            // The instantiator of this class should queue more operations in the completion block.
            self.shouldRepeat = true
            self.completeOperation()
        }
        urlSessionTask?.resume()
    }
}
