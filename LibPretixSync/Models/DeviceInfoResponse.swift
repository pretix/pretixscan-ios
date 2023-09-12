//
//  DeviceInfoResponse.swift
//  pretixSCAN
//
//  Created by Konstantin on 29/03/2023.
//  Copyright © 2023 rami.io. All rights reserved.
//

import Foundation


public struct DeviceInfoResponse: Codable, Equatable {
    let server: ServerInfo?
    let device: DeviceInfoData?
}

public struct ServerInfo: Codable, Equatable {
    let version: ServerVersionInfo?
}

public struct ServerVersionInfo: Codable, Equatable {
    let pretix: String?
    let pretixNumeric: Int?
    
    private enum CodingKeys: String, CodingKey {
        case pretixNumeric = "pretix_numeric"
        case pretix
    }
}

public struct DeviceInfoData: Codable, Equatable {
    let gate: DeviceInfoGate?
}

public struct DeviceInfoGate: Codable, Equatable {
    let id: Identifier
    let name: String
}
