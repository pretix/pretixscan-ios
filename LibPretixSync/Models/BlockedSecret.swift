// Created by konstantin on 11/02/2023.
// Copyright (c) 2023. All rights reserved.

import Foundation
import FMDB

public struct BlockedSecret: Model {
    public static let humanReadableName = "BlockedSecret"
    public static let stringName = "blockedsecrets"
    public let id: Identifier
    public let secret: String
    public let blocked: Bool
}

extension BlockedSecret: Equatable {
    public static func == (lhs: BlockedSecret, rhs: BlockedSecret) -> Bool {
        return lhs.id == rhs.id
    }
}

extension BlockedSecret: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

