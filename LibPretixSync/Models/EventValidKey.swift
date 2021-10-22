//
//  EventKey.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 22/10/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation
import FMDB

public struct EventValidKey: Model {
    public static let humanReadableName = "EventValidKeys"
    public static let stringName = "eventkeys"
    public let secret: String
}

extension EventValidKey {
    init(key: String) {
        self.secret = key
    }
}

extension EventValidKey: Equatable {
    public static func == (lhs: EventValidKey, rhs: EventValidKey) -> Bool {
        return lhs.secret == rhs.secret
    }
}

extension EventValidKey: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.secret)
    }
}
