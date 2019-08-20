//
//  Order.swift
//  PretixScan
//
//  Created by Daniel Jilg on 08.04.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

public struct Order: Model {
    public static let humanReadableName = "Order"
    public static let stringName = "orders"

    public let code: String
    public let status: Status

    /// If `true`, this order was created when the event was in test mode.
    /// Only orders in test mode can be deleted.
    public let testMode: Bool = false

    /// The secret contained in the link sent to the customer
    public let secret: String

    /// The customer email address
    public let email: String?

    /// The locale used for communication with this customer
    public let locale: RegionCode?

    /// Channel this sale was created through, such as `"web"`.
    public let salesChannel: String?

    /// Time of order creation
    public let createdAt: String?

    /// The order will expire, if it is still pending by this time
    public let expiresAt: Date?

    /// Last modification of this object
    public let lastModifiedAt: Date?

    /// Total value of this order
    public let total: Money?

    /// Internal comment on this order
    public let comment: String?

    /// If `true`, the check-in app should show a warning that this
    /// ticket requires special attention if a ticket of this order is scanned.
    public let checkInAttention: Bool?

    /// List of non-canceled order positions
    public let positions: [OrderPosition]?

    /// If true and the order is pending, this order needs approval by an
    /// organizer before it can continue. If true and the order is canceled,
    /// this order has been denied by the event organizer.
    public let requireApproval: Bool?

    private enum CodingKeys: String, CodingKey {
        case code
        case status
        case testMode = "testmode"
        case secret
        case email
        case locale
        case salesChannel = "sales_channel"
        case createdAt = "datetime"
        case expiresAt = "expires"
        case lastModifiedAt = "last_modified"
        case total
        case comment
        case checkInAttention = "checkin_attention"
        case positions
        case requireApproval = "require_approval"
    }

    public enum Status: String, Codable, Equatable {
        case pending = "n"
        case paid = "p"
        case expired = "e"
        case canceled = "c"
    }

    static func stubOrder(code: String, status: Order.Status, secret: String) -> Order {
        return Order(code: code, status: status, secret: secret, email: nil, locale: nil,
                     salesChannel: nil, createdAt: nil, expiresAt: nil, lastModifiedAt: nil,
                     total: nil, comment: nil, checkInAttention: nil, positions: nil,
                     requireApproval: nil)
    }
}

extension Order: Equatable {
    public static func == (lhs: Order, rhs: Order) -> Bool {
        return lhs.code == rhs.code
    }
}

extension Order: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.code)
    }
}
