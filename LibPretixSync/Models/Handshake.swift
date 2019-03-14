//
//  Handshake.swift
//  PretixScan
//
//  Created by Daniel Jilg on 14.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

/// Represents the data a device needs to connect to the Pretix API. Usually in form of a QR code. 
///
/// REST Docs: https://docs.pretix.eu/en/latest/api/deviceauth.html
///
/// ## JSON Example:
/// ```{"handshake_version": 1, "url": "https://pretix.eu", "token": "kpp4jn8g2ynzonp6"}```
public struct Handshake: Codable, Equatable {
    /// Handshake Version. We expect it to be 1
    public let version: Int = 1

    /// The Base URL for the Pretix API
    public let url: URL

    /// A handshake token
    public let token: String

    private enum CodingKeys: String, CodingKey {
        case version = "handshake_version"
        case url
        case token
    }
}
