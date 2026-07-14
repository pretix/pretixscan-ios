//
//  MediaPolicy.swift
//  PretixScan
//
//  Created by Konstantin Kostov on 15/07/2026.
//  Copyright © 2026 rami.io. All rights reserved.
//

import Foundation

/// Determines how reusable media are handled for check-ins of an `Item`.
public enum MediaPolicy: String, Codable, UnknownCase {
    public static var unknownCase = MediaPolicy.none

    case none
    case new
    case reuse
    case reuseOrNew = "reuse_or_new"
    case append
    case appendOrNew = "append_or_new"
}
