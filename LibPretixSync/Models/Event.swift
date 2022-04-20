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
public struct Event: Model {
    public static let humanReadableName = "Events"
    public static let stringName = "events"

    /// The event’s full name
    public let name: MultiLingualString

    /// A short form of the name, used e.g. in URLs.
    public let slug: String

    /// The event’s start date
    public let dateFrom: Date?
    
    /// The event’s end date
    public let dateTo: Date?
    
    /// The event’s admission date
    public let dateAdmission: Date?

    /// `True` if the event has sub events
    public let hasSubEvents: Bool
    
    public let validKeys: EventValidKeys?

    private enum CodingKeys: String, CodingKey {
        case name
        case slug
        case dateFrom = "date_from"
        case dateTo = "date_to"
        case dateAdmission = "date_admission"
        case hasSubEvents = "has_subevents"
        case validKeys = "valid_keys"
    }
}

extension Event: Equatable {
    public static func == (lhs: Event, rhs: Event) -> Bool {
        return lhs.slug == rhs.slug
    }
}

extension Event: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.slug)
    }
}
