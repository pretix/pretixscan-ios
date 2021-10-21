//
//  RevokedSecrets.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 21/10/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation
import FMDB

public struct RevokedSecret: Model {
    public static let humanReadableName = "RevokedSecrets"
    public static let stringName = "revokedsecrets"
    public let id: Identifier
    public let secret: String
}

extension RevokedSecret: Equatable {
    public static func == (lhs: RevokedSecret, rhs: RevokedSecret) -> Bool {
        return lhs.id == rhs.id
    }
}

extension RevokedSecret: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
