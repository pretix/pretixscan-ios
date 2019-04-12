//
//  Model.swift
//  PretixScan
//
//  Created by Daniel Jilg on 12.04.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

public protocol Model: Codable, Equatable {
    static var urlPathPart: String { get }
    static var humanReadableName: String { get }
}
