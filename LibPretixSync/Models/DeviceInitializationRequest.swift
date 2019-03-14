//
//  DeviceInitializationRequest.swift
//  PretixScan
//
//  Created by Daniel Jilg on 14.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

/// Represents the request to initialize a device.
///
/// After your application received the token, you need to call the initialization endpoint to
/// obtain a proper API token. At this point, you need to identify the name and version of your
/// application, as well as the type of underlying hardware.
///
/// ## JSON Example:
///
/// ```json
/// {
///     "token": "kpp4jn8g2ynzonp6",
///     "hardware_brand": "Samsung",
///     "hardware_model": "Galaxy S",
///     "software_brand": "pretixdroid",
///     "software_version": "4.0.0"
/// }
public struct DeviceInitializationRequest: Codable, Equatable {
    public let token: String
    public let hardwareBrand: String
    public let hardwareModel: String
    public let softwareBrand: String
    public let softwareVersion: String

    private enum CodingKeys: String, CodingKey {
        case token
        case hardwareBrand = "hardware_brand"
        case hardwareModel = "hardware_model"
        case softwareBrand = "software_brand"
        case softwareVersion = "software_version"
    }
}
