//
//  DelayOperation.swift
//  DelayOperation
//
//  Created by Konstantin Kostov on 13/08/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation

/// Delayed NSOperation which can be inserted in a serial queue in order to postpone execution of other tasks.
class DelayedBlockOperation: Operation {
    private var delay: TimeInterval
    private var queue: DispatchQueue = .main
    var delayWorkItem: DispatchWorkItem? = nil
    
    init(delay: TimeInterval) {
        self.delay = delay
        super.init()
    }
    
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
    
    func completeOperation() {
        isFinished = true
        isExecuting = false
    }
    
    override func start() {
        if isCancelled {
            completeOperation()
            return
        }
        isExecuting = true
        
        delayWorkItem = DispatchWorkItem {[weak self] in
            self?.completeOperation()
        }
        
        queue.asyncAfter(deadline: .now() + delay, execute: delayWorkItem!)
    }
    
    override func cancel() {
        super.cancel()
        if isExecuting {
            isFinished = true
            isExecuting = false
        }
        delayWorkItem?.cancel()
    }
}
