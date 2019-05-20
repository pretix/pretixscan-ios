//
//  ItemCategory.swift
//  PretixScan
//
//  Created by Daniel Jilg on 09.04.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

/// Categories provide grouping for items (better known as products)
public struct ItemCategory: Model {
    public static let humanReadableName = "Category"
    public static let stringName = "categories"

    /// Internal ID of the category
    public let identifier: Identifier

    /// The category’s visible name
    public let name: MultiLingualString

    /// An optional name that is only used in the backend
    public let internalName: String?

    /// A public description (might include markdown)
    public let description: MultiLingualString?

    /// Used for sorting
    public let position: Int

    /// If `true`, items within this category are not on sale on their own
    /// but the category provides a source for defining add-ons for other products.
    public let isAddon: Bool

    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case internalName = "internal_name"
        case description
        case position
        case isAddon = "is_addon"
    }
}

extension ItemCategory: Equatable {
    public static func == (lhs: ItemCategory, rhs: ItemCategory) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

extension ItemCategory: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.identifier)
    }
}
