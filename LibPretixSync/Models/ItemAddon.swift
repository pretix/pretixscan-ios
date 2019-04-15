//
//  ItemAddon.swift
//  PretixScanTests
//
//  Created by Daniel Jilg on 09.04.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

/// Add-ons that can be chosen for an item
public struct ItemAddon: Codable, Equatable {
    /// Internal ID of the item category the add-on can be chosen from.
    public let itemCategoryIdentifier: Identifier

    /// The minimal number of add-ons that need to be chosen.
    public let minCount: Int?

    /// The maximum number of add-ons that can be chosen.
    public let maxCount: Int?

    /// Used for sorting
    public let position: Int

    /// Adding this add-on to the item is free
    public let priceIncluded: Bool

    private enum CodingKeys: String, CodingKey {
        case itemCategoryIdentifier = "addon_category"
        case minCount = "min_count"
        case maxCount = "max_count"
        case position
        case priceIncluded = "price_included"
    }
}
