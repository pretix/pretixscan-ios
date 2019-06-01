//
//  OrderPosition.swift
//  PretixScan
//
//  Created by Daniel Jilg on 19.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

/// Part of an Order
public struct OrderPosition: Model {
    public static let humanReadableName = "Order Position"
    public static let stringName = "orderpositions"

    /// Internal ID of the order position
    public let identifier: Identifier

    /// Order code of the order the position belongs to
    public let orderCode: String

    /// The `Order` this position belongs to.
    ///
    /// (May be nil if not pre-fetched by the database. Fall back on `orderCode` in that case)
    public var order: Order?

    /// Number of the position within the order
    public let positionid: Identifier

    /// ID of the purchased item
    public let itemIdentifier: Identifier

    /// The purchased `Item`.
    ///
    /// (May be nil if not pre-fetched by the database. Fall back on `itemIdentifier` in that case)
    public var item: Item?

    /// ID of the purchased variation (if any)
    public let variation: Identifier?

    /// Price of this position
    public let price: Money

    /// Specified attendee name for this position
    public let attendeeName: String?

    /// Specified attendee email address for this position
    public let attendeeEmail: String?

    /// Secret code printed on the tickets for validation
    public let secret: String

    /// A random ID, e.g. for use in lead scanning apps
    public let pseudonymizationId: String

    /// List of check-ins with this ticket
    public let checkins: [CheckIn]

    /// Ticket has already been used
    public var isRedeemed: Bool {
        return checkins.count > 0
    }

    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case orderCode = "order"
        case positionid
        case itemIdentifier = "item"
        case variation
        case price
        case attendeeName = "attendee_name"
        case attendeeEmail = "attendee_email"
        case secret
        case pseudonymizationId = "pseudonymization_id"
        case checkins
    }
}
