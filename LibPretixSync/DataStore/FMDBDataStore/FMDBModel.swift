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
public protocol FMDBModel: Model {
    static var creationQuery: String { get }
    static var destructionQuery: String { get }
    static var insertQuery: String { get }
}

public extension FMDBModel {
    static var destructionQuery: String { return "DROP TABLE IF EXISTS \"\(stringName)\"" }
}

public extension Model {
    func toJSONString() -> String? {
        if let data = try? JSONEncoder.iso8601withFractionsEncoder.encode(self) {
            return String(data: data, encoding: .utf8)
        }

        return nil
    }
}
