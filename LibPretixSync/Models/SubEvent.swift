//
//  SubEvent.swift
//  pretixSCAN
//
//  Created by Daniel Jilg on 10.05.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation
import FMDB

/// `Event`s can represent whole event series
///
/// if the has_subevents property of the event is active. In this case,
/// many other resources are additionally connected to an event date
/// (also called sub-event).
public struct SubEvent: Model {
    public static let humanReadableName = "Sub Event"
    public static let stringName = "subevents"

    /// Internal ID of the sub-event
    public let identifier: Identifier

    /// The sub-event’s full name
    public let name: MultiLingualString

    /// The slug of the parent event
    public let event: String

    /// If true, the sub-event ticket shop is publicly available.
    public let isActive: Bool

    /// If true, the sub-event ticket shop is publicly shown in lists.
    public let isPublic: Bool

    /// The sub-event’s start date
    public let dateFrom: Date

    /// The sub-event’s end date
    public let dateTo: Date?

    /// The sub-event’s admission date
    public let dateAdmission: Date?

    /// The sub-date at which the ticket shop opens
    public let presaleStart: Date?

    /// The sub-date at which the ticket shop closes
    public let presaleEnd: Date?

    /// The sub-event location
    public let location: MultiLingualString?

    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case event
        case isActive = "active"
        case isPublic = "is_public"
        case dateFrom = "date_from"
        case dateTo = "date_to"
        case dateAdmission = "date_admission"
        case presaleStart = "presale_start"
        case presaleEnd = "presale_end"
        case location
    }
    
    static var searchByEventQuery = """
    SELECT * FROM "\(stringName)" WHERE event=?;
    """
    
    static var searchById = """
    SELECT * FROM "\(stringName)" WHERE id=?;
    """
    
    static func from(result: FMResultSet, in database: FMDatabase) -> SubEvent? {
        guard let json = result.string(forColumn: "json"), let jsonData = json.data(using: .utf8) else { return nil }
        guard let subEvent = try? JSONDecoder.iso8601withFractionsDecoder.decode(SubEvent.self, from: jsonData) else { return nil }

        return subEvent
    }
}

extension SubEvent: Equatable {
    public static func == (lhs: SubEvent, rhs: SubEvent) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

extension SubEvent: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.identifier)
    }
}
