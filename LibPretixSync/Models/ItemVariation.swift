//
//  ItemVariation.swift
//  PretixScanTests
//
//  Created by Daniel Jilg on 09.04.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

/// Variation of an Item
public struct ItemVariation: Codable, Equatable {
    /// Internal ID of the variation
    public let identifier: Identifier

    /// The “name” of the variation
    public let name: MultiLingualString

    /// The price set directly for this variation or `nil`
    public let defaultPrice: Money?

    /// The price used for this variation.
    ///
    /// This is either the same as `default_price` if that value is set or equal to the item’s `default_price`.
    public let price: Money

    /// If `false`, this variation will not be sold or shown.
    public let active: Bool

    /// A public description of the variation. May contain Markdown syntax or can be `nil`
    public let description: MultiLingualString?

    /// Used for sorting
    public let position: Int
    
    /// If true, the check-in app should show a warning that this ticket requires special attention if such a variation is being scanned.
    public let checkInAttention: Bool?
    
    /// Additional text to be shown when this ticket is canned
    public let checkInText: String?

    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name = "value"
        case defaultPrice = "default_price"
        case price
        case active
        case description
        case position
        case checkInAttention = "checkin_attention"
        case checkInText = "checkin_text"
    }
}
