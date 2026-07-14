//
//  Item.swift
//  PretixScanTests
//
//  Created by Daniel Jilg on 09.04.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

/// Items (better known as products) are the things that can be sold using pretix
public struct Item: Model {
    public static let humanReadableName = "Item"
    public static let stringName = "items"

    /// Internal ID of the item
    public let identifier: Identifier

    /// The item’s visible name
    public var name: MultiLingualString

    /// An optional name that is only used in the backend
    public let internalName: String?

    /// The item price that is applied if the price is not overwritten by variations or other options.
    public let defaultPrice: Money

    /// The ID of the category this item belongs to
    public let categoryIdentifier: Identifier?

    /// If `false`, the item is hidden from all public lists and will not be sold
    public let active: Bool

    /// A public description of the item. May contain Markdown syntax
    public var description: MultiLingualString?

    /// If true, customers can change the price at which they buy the product
    ///
    /// However, the price can’t be set lower than the price defined by default_price
    public let freePrice: Bool

    /// The VAT rate to be applied for this item.
    public let taxRate: String

    /// The internal ID of the applied tax rule
    public let taxRuleIdentifier: Identifier?

    /// `true` for items that grant admission to the event (such as primary tickets) and `false` for others (such as add-ons or merchandise)
    public let admission: Bool

    /// Used for sorting
    public let position: Int

    /// A product picture to be displayed in the shop
    public let picture: String?

    /// Sales channels this product is available on, such as `"web"` or `"resellers"`. Defaults to `["web"]`.
    public let salesChannels: [String]

    /// The first date time at which this item can be bought
    public let availableFrom: Date?

    /// The last date time at which this item can be bought
    public let availableUntil: Date?

    /// If `true`, this item can only be bought using a voucher that is specifically assigned to this item.
    public let requireVoucher: Bool

    /// If `true`, this item is only shown during the voucher redemption process, but not in the normal shop frontend.
    public let hideWithoutVoucher: Bool

    /// If `false`, customers cannot cancel orders containing this item.
    public let allowCancel: Bool

    /// This product can only be bought if it is included at least this many times in the order (or `nil` for no limitation).
    public let minPerOrder: Int?

    /// This product can only be bought if it is included at most this many times in the order (or `nil` for no limitation).
    public let maxPerOrder: Int?

    /// If true, the check-in app should show a warning that this ticket requires special attention if such a product is being scanned.
    public let checkInAttention: Bool

    /// An original price, shown for comparison, not used for price calculations
    public let originalPrice: Money?

    /// If `true`, orders with this product will need to be approved by the event organizer before they can be paid.
    public let requireApproval: Bool

    /// If `true`, this item is only available as part of bundles.
    public let requireBundling: Bool

    /// Force Ticket Generation
    ///
    /// If `false`, tickets are never generated for this product, regardless of other settings.
    /// If `true`, tickets are generated even if this is a non-admission or add-on product, regardless of event settings.
    /// If this is `nil`, regular ticketing rules apply.
    public let generateTickets: Bool?
    
    /// Additional text to be shown when this ticket is canned
    public let checkInText: String?

    /// Shows whether or not this item has variations.
    public let hasVariations: Bool

    /// A list with one object for each variation of this item
    public let variations: [ItemVariation]

    /// Definition of add-ons that can be chosen for this item
    public let addons: [ItemAddon]

    /// Definition of bundles that are included in this item
    public let bundles: [ItemBundle]

    /// How reusable media are handled for check-ins of this item. Defaults to `.none`.
    public let mediaPolicy: MediaPolicy

    /// The type of reusable medium required by this item. Defaults to `.none`.
    public let mediaType: ReusableMediaType

    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case internalName = "internal_name"
        case defaultPrice = "default_price"
        case categoryIdentifier = "category"
        case active
        case description
        case freePrice = "free_price"
        case taxRate = "tax_rate"
        case taxRuleIdentifier = "tax_rule"
        case admission
        case position
        case picture
        case salesChannels = "sales_channels"
        case availableFrom = "available_from"
        case availableUntil = "available_until"
        case requireVoucher = "require_voucher"
        case hideWithoutVoucher = "hide_without_voucher"
        case allowCancel = "allow_cancel"
        case minPerOrder = "min_per_order"
        case maxPerOrder = "max_per_order"
        case checkInAttention = "checkin_attention"
        case originalPrice = "original_price"
        case requireApproval = "require_approval"
        case requireBundling = "require_bundling"
        case generateTickets = "generate_tickets"
        case hasVariations = "has_variations"
        case variations
        case addons
        case bundles
        case checkInText = "checkin_text"
        case mediaPolicy = "media_policy"
        case mediaType = "media_type"
    }

}

extension Item {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try container.decode(Identifier.self, forKey: .identifier)
        name = try container.decode(MultiLingualString.self, forKey: .name)
        internalName = try container.decodeIfPresent(String.self, forKey: .internalName)
        defaultPrice = try container.decode(Money.self, forKey: .defaultPrice)
        categoryIdentifier = try container.decodeIfPresent(Identifier.self, forKey: .categoryIdentifier)
        active = try container.decode(Bool.self, forKey: .active)
        description = try container.decodeIfPresent(MultiLingualString.self, forKey: .description)
        freePrice = try container.decode(Bool.self, forKey: .freePrice)
        taxRate = try container.decode(String.self, forKey: .taxRate)
        taxRuleIdentifier = try container.decodeIfPresent(Identifier.self, forKey: .taxRuleIdentifier)
        admission = try container.decode(Bool.self, forKey: .admission)
        position = try container.decode(Int.self, forKey: .position)
        picture = try container.decodeIfPresent(String.self, forKey: .picture)
        salesChannels = try container.decode([String].self, forKey: .salesChannels)
        availableFrom = try container.decodeIfPresent(Date.self, forKey: .availableFrom)
        availableUntil = try container.decodeIfPresent(Date.self, forKey: .availableUntil)
        requireVoucher = try container.decode(Bool.self, forKey: .requireVoucher)
        hideWithoutVoucher = try container.decode(Bool.self, forKey: .hideWithoutVoucher)
        allowCancel = try container.decode(Bool.self, forKey: .allowCancel)
        minPerOrder = try container.decodeIfPresent(Int.self, forKey: .minPerOrder)
        maxPerOrder = try container.decodeIfPresent(Int.self, forKey: .maxPerOrder)
        checkInAttention = try container.decode(Bool.self, forKey: .checkInAttention)
        originalPrice = try container.decodeIfPresent(Money.self, forKey: .originalPrice)
        requireApproval = try container.decode(Bool.self, forKey: .requireApproval)
        requireBundling = try container.decode(Bool.self, forKey: .requireBundling)
        generateTickets = try container.decodeIfPresent(Bool.self, forKey: .generateTickets)
        checkInText = try container.decodeIfPresent(String.self, forKey: .checkInText)
        hasVariations = try container.decode(Bool.self, forKey: .hasVariations)
        variations = try container.decode([ItemVariation].self, forKey: .variations)
        addons = try container.decode([ItemAddon].self, forKey: .addons)
        bundles = try container.decode([ItemBundle].self, forKey: .bundles)
        mediaPolicy = try container.decodeIfPresent(MediaPolicy.self, forKey: .mediaPolicy) ?? .none
        mediaType = try container.decodeIfPresent(ReusableMediaType.self, forKey: .mediaType) ?? .none
    }
}

extension Item: Equatable {
    public static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

extension Item: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.identifier)
    }
}
