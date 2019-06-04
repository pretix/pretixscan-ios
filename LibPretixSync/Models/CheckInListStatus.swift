//
//  StatusItem.swift
//  PretixScan
//
//  Created by Daniel Jilg on 27.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//
// swiftlint:disable nesting

import Foundation

/// Collection of Status information for a CheckIn-List, such as the number of checked-in attendees
public struct CheckInListStatus: Codable, Equatable {
    /// The amount of checked-in attendees
    public let checkinCount: Int

    /// The amount of order positions sold, meaning the amount of attendees to expect
    public let positionCount: Int

    /// The items to be checked in
    public let items: [Item]

    private enum CodingKeys: String, CodingKey {
        case checkinCount = "checkin_count"
        case positionCount = "position_count"
        case items
    }

    /// An item to be checked in, e.g. "Student Ticket", "Regular Ticket", or "T-Shirt"
    public struct Item: Codable, Equatable {
        // TODO: Check if we can remove this and replace it with the global `Item` model
        public let name: String
        public let identifier: Identifier
        public let checkinCount: Int
        public let admission: Bool
        public let positionCount: Int
        public let variations: [Variation]?

        private enum CodingKeys: String, CodingKey {
            case name
            case identifier = "id"
            case checkinCount = "checkin_count"
            case admission
            case positionCount = "position_count"
            case variations
        }

        /// A variant of Event Status Items, e.g. "XL T-Shirt"
        public struct Variation: Codable, Equatable {
            public let value: String
            public let identifier: Int
            public let checkinCount: Int
            public let positionCount: Int

            private enum CodingKeys: String, CodingKey {
                case value
                case identifier = "id"
                case checkinCount = "checkin_count"
                case positionCount = "position_count"
            }
        }
    }
}
