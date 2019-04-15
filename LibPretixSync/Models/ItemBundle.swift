//
//  ItemBundle.swift
//  PretixScanTests
//
//  Created by Daniel Jilg on 09.04.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

/// Bundle that is included in an Item
public struct ItemBundle: Codable, Equatable {
    /// Internal ID of the item that is included.
    public let bundledItemIdentifier: Identifier

    /// Internal ID of the variation of the item if any
    public let bundledVariationIdentfier: Identifier?

    /// Number of items included
    public let count: Int

    /// Designated price of the bundled product.
    ///
    /// This will be used to split the price of the base item e.g. for mixed taxation. This is not added to the price.
    public let designatedPrice: Money

    private enum CodingKeys: String, CodingKey {
        case bundledItemIdentifier = "bundled_item"
        case bundledVariationIdentfier = "bundled_variation"
        case count
        case designatedPrice = "designated_price"
    }
}
