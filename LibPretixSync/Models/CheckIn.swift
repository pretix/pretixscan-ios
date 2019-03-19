//
//  CheckIn.swift
//  PretixScan
//
//  Created by Daniel Jilg on 19.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

/// A check-in with a ticket in a CheckIn List
public struct CheckIn: Codable, Equatable {
    /// Internal ID of the check-in list
    public let listID: Int

    /// Time of check-in
    public let date: Date

    private enum CodingKeys: String, CodingKey {
        case listID = "list"
        case date = "datetime"
    }
}
