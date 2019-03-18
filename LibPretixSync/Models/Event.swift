//
//  Event.swift
//  PretixScan
//
//  Created by Daniel Jilg on 15.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

/// An Event managed by Pretix
///
/// Source: https://docs.pretix.eu/en/latest/api/resources/events.html
public struct Event: Codable, Equatable {
    /// The event’s full name
    public let name: MultiLingualString

    /// A short form of the name, used e.g. in URLs.
    public let slug: String

    /// The event’s start date
    public let dateFrom: Date?

    private enum CodingKeys: String, CodingKey {
        case name
        case slug
        case dateFrom = "date_from"
    }
}
