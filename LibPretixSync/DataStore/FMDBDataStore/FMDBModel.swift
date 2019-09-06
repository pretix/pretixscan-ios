//
//  FMDBModel.swift
//  pretixSCAN
//
//  Created by Daniel Jilg on 16.05.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation
import FMDB

// MARK: - Protocol
protocol FMDBModel: Model {
    static var creationQuery: String { get }
    static var destructionQuery: String { get }
    static var insertQuery: String { get }

    /// Any queries that should be run to update the database model. Failures will be silently ignored.
    static var updateQueries: [String] { get }
}

extension FMDBModel {
    static var destructionQuery: String { return "DROP TABLE IF EXISTS \"\(stringName)\"" }
    static var updateQueries: [String] { return [] }
}

public extension Model {
    /// Returns the model's representation as a String containing JSON.
    ///
    /// You should use `JSONDecoder.iso8601withFractionsDecoder` to decode the string again.
    func toJSONString() -> String? {
        if let data = try? JSONEncoder.iso8601withFractionsEncoder.encode(self) {
            return String(data: data, encoding: .utf8)
        }

        return nil
    }
}
