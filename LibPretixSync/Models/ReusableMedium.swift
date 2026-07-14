//
//  ReusableMedium.swift
//  PretixScan
//
//  Created by Konstantin Kostov on 14/07/2026.
//  Copyright © 2026 rami.io. All rights reserved.
//

import Foundation

/// A physical carrier (e.g. a printed barcode card) linked to one or more order positions.
///
/// Source: https://docs.pretix.eu/en/latest/api/resources/reusablemedia.html
public struct ReusableMedium: Model {
    public static let humanReadableName = "Reusable Medium"
    public static let stringName = "reusablemedia"

    /// Server "id"
    public let identifier: Identifier

    /// e.g. "barcode", "nfc_uid"
    public let type: String

    /// Server "identifier": the value printed/encoded on the medium
    public let mediumIdentifier: String

    public let active: Bool

    public let expires: Date?

    /// Server "created": used to resume a full sync after an interrupted page fetch.
    public let created: Date

    public let customer: String?

    /// Server IDs of the linked order positions, from "linked_orderpositions", falling back to
    /// wrapping the deprecated scalar "linked_orderposition" when absent.
    public let linkedOrderPositions: [Identifier]

    public let linkedGiftCard: Identifier?

    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case type
        case mediumIdentifier = "identifier"
        case active
        case expires
        case created
        case customer
        case linkedOrderPositions = "linked_orderpositions"
        case linkedOrderPosition = "linked_orderposition"
        case linkedGiftCard = "linked_giftcard"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try container.decode(Identifier.self, forKey: .identifier)
        type = try container.decode(String.self, forKey: .type)
        mediumIdentifier = try container.decode(String.self, forKey: .mediumIdentifier)
        active = try container.decode(Bool.self, forKey: .active)
        expires = try container.decodeIfPresent(Date.self, forKey: .expires)
        created = try container.decode(Date.self, forKey: .created)
        customer = try container.decodeIfPresent(String.self, forKey: .customer)
        linkedGiftCard = try container.decodeIfPresent(Identifier.self, forKey: .linkedGiftCard)

        if let linkedOrderPositions = try container.decodeIfPresent([Identifier].self, forKey: .linkedOrderPositions) {
            self.linkedOrderPositions = linkedOrderPositions
        } else if let linkedOrderPosition = try container.decodeIfPresent(Identifier.self, forKey: .linkedOrderPosition) {
            linkedOrderPositions = [linkedOrderPosition]
        } else {
            linkedOrderPositions = []
        }
    }

    public init(identifier: Identifier, type: String, mediumIdentifier: String, active: Bool, expires: Date?,
                created: Date = Date(), customer: String?, linkedOrderPositions: [Identifier], linkedGiftCard: Identifier?) {
        self.identifier = identifier
        self.type = type
        self.mediumIdentifier = mediumIdentifier
        self.active = active
        self.expires = expires
        self.created = created
        self.customer = customer
        self.linkedOrderPositions = linkedOrderPositions
        self.linkedGiftCard = linkedGiftCard
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(type, forKey: .type)
        try container.encode(mediumIdentifier, forKey: .mediumIdentifier)
        try container.encode(active, forKey: .active)
        try container.encodeIfPresent(expires, forKey: .expires)
        try container.encode(created, forKey: .created)
        try container.encodeIfPresent(customer, forKey: .customer)
        try container.encode(linkedOrderPositions, forKey: .linkedOrderPositions)
        try container.encodeIfPresent(linkedGiftCard, forKey: .linkedGiftCard)
    }
}

extension ReusableMedium: Equatable {
    public static func == (lhs: ReusableMedium, rhs: ReusableMedium) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

extension ReusableMedium: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.identifier)
    }
}
