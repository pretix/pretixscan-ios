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
