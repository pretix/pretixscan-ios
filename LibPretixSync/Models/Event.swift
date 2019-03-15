//
//  Event.swift
//  PretixScan
//
//  Created by Daniel Jilg on 15.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

struct Event: Codable, Equatable {
    public let name: String
    public let slug: String
    public let dateFrom: Date?

    private enum CodingKeys: String, CodingKey {
        case name
        case slug
        case dateFrom = "date_from"
    }
}
