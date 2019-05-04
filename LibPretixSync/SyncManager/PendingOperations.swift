//
//  PendingOperations.swift
//  PretixScan
//
//  Created by Daniel Jilg on 04.05.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

class PendingOperations {
    lazy var downloadsInProgress: [String: Operation] = [:]
    lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download Queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    lazy var uploadsInProgress: [String: Operation] = [:]
    lazy var uploadQeuue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Upload Queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
}
