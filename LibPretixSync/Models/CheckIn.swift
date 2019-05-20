//
//  CheckIn.swift
//  PretixScan
//
//  Created by Daniel Jilg on 19.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

/// A check-in with a ticket in a CheckIn List
public struct CheckIn: Model {
    public static let humanReadableName = "Check-In"
    public static let stringName = "checkins"

    /// Internal ID of the check-in list
    public let listID: Identifier

    /// Time of check-in
    public let date: Date

    private enum CodingKeys: String, CodingKey {
        case listID = "list"
        case date = "datetime"
    }
}
