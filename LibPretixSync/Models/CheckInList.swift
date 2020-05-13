//
//  CheckInList.swift
//  PretixScan
//
//  Created by Daniel Jilg on 18.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

/// You can create check-in lists that you can use e.g. at the entrance
/// of your event to track who is coming and if they actually bought a ticket.
///
/// You can create multiple check-in lists to separate multiple parts of your event, for example
/// if you have separate entries for multiple ticket types. Different check-in lists are completely
/// independent: If a ticket shows up on two lists, it is valid once on every list. This might be
/// useful if you run a festival with festival passes that allow access to every or multiple
/// performances as well as tickets only valid for single performances.
///
/// Source: https://docs.pretix.eu/en/latest/api/resources/checkinlists.html
public struct CheckInList: Model {
    public static let humanReadableName = "Check-In List"
    public static let stringName = "checkinlists"

    /// Internal ID of the check-in list
    public let identifier: Identifier

    /// The internal name of the check-in list
    public let name: String

    /// If `true`, the check-in lists contains tickets of all products in this event. The
    /// `limitProducts` field is ignored in this case.
    public let allProducts: Bool

    /// List of item IDs to include in this list.
    public let limitProducts: [Int]?

    /// ID of the date inside an event series this list belongs to (or null).
    public let subEvent: Identifier?

    /// Number of tickets that match this list
    public let positionCount: Int

    /// Number of check-ins performed on this list
    public let checkinCount: Int

    /// If `true`, the check-in list also contains tickets from orders in pending state.
    public let includePending: Bool
    
    public let allowEntryAfterExit: Bool
    
    public let allowMultipleEntries: Bool

    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case allProducts = "all_products"
        case limitProducts = "limit_products"
        case subEvent = "subevent"
        case positionCount = "position_count"
        case checkinCount = "checkin_count"
        case includePending = "include_pending"
        case allowEntryAfterExit = "allow_entry_after_exit"
        case allowMultipleEntries = "allow_multiple_entries"
    }
}

extension CheckInList: Equatable {
    public static func == (lhs: CheckInList, rhs: CheckInList) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

extension CheckInList: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.identifier)
    }
}
