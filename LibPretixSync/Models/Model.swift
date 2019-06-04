//
//  Model.swift
//  PretixScan
//
//  Created by Daniel Jilg on 12.04.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

/// An entity that can be synced with the API or stored locally
public protocol Model: Codable, Hashable {
    /// A human name for the model, used in logging and UI
    static var humanReadableName: String { get }

    /// Appended to the base URL to retrieve the model, use as table name, etc.
    static var stringName: String { get }
}
