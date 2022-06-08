//
//  EventLogger.swift
//  pretixSCAN
//
//  Created by Daniel Jilg on 23.06.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation
import os.log
import Sentry

/// Wrapper class that logs events to both Sentry and the System OS Log
public struct EventLogger {
    /// Log an event
    public static func log(event eventMessage: String, category: Category, level: SentryLevel, type: OSLogType) {
        // Log to OS Log
        let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: category.rawValue)
        os_log(type, log: log, "%@", eventMessage)
        
        // Log to Sentry
        let event = Sentry.Event(level: level)
        event.message = SentryMessage(formatted: eventMessage)
        event.extra = ["category": category.rawValue, "type": type.rawValue]
        SentrySDK.capture(event: event)

        // If fatal, crash
        if level == .fatal {
            fatalError(eventMessage)
        }
    }

    /// Possible categories for an event
    public enum Category: String {
        case configuration
        case network
        case offlineUpload
        case offlineDownload
        case database
        case avCaptureDevice
        case parsing
        case rules
        case general
    }
}
