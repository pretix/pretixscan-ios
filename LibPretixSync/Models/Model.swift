//
//  Model.swift
//  PretixScan
//
//  Created by Daniel Jilg on 12.04.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

public protocol Model: Codable, Equatable {
    /// A human name for the model, used in logging and UI
    static var humanReadableName: String { get }

    /// Appended to the base URL to retrieve the model
    static var urlPathPart: String { get }
}
