//
//  EventValidKeys.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 12/10/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation


public struct EventValidKeys: Hashable, Equatable, Codable {
    public let pems: [String]
    
    private enum CodingKeys: String, CodingKey {
        case pems = "pretix_sig1"
    }
}
