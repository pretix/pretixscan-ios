//
//  DeviceInitializationResponse.swift
//  PretixScan
//
//  Created by Daniel Jilg on 14.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

/// Represents the response to a DeviceInitializationRequest
///
/// Every initialization token can only be used once. On success, you will receive a response
/// containing information on your device as well as your API token:
///
/// Please make sure that you store this api_token value. We also recommend storing your
/// device ID, your assigned unique_serial, and the organizer you have access to, but that’s
/// up to you.
///
/// ## JSON Example:
///
/// ```json
/// {
///     "organizer": "foo",
///     "device_id": 5,
///     "unique_serial": "HHZ9LW9JWP390VFZ",
///     "api_token": "1kcsh572fonm3hawalrncam4l1gktr2rzx25a22l8g9hx108o9oi0rztpcvwnfnd",
///     "name": "Bar"
/// }
public struct DeviceInitializationResponse: Codable, Equatable {
    public let organizer: String
    public let deviceID: Identifier
    public let uniqueSerial: String
    public let apiToken: String
    public let name: String

    private enum CodingKeys: String, CodingKey {
        case organizer
        case deviceID = "device_id"
        case uniqueSerial = "unique_serial"
        case apiToken = "api_token"
        case name
    }
}
