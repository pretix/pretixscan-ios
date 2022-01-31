//
//  Logger.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 16/09/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation
import OSLog

/// A simple logger which outputs to the unified logger system
var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "main")

extension Logger {
    /// As long as the app is running in DEBUG mode, try to deserialize and print the contents of Data as a string
    func debugRawDataAsString(_ data: Data) {
        #if DEBUG
        guard let string = String(data: data, encoding: .utf8) else {
            self.warning("↘️: <🍅 data failed to serialize to a string>")
            return
        }
        logger.debug("↘️: \(string)")
        #endif
    }
}
