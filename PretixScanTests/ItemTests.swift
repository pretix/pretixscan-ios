//
//  ItemTests.swift
//  PretixScanTests
//
//  Created by Daniel Jilg on 09.04.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import XCTest

class ItemTests: XCTestCase {
    private let jsonDecoder = JSONDecoder.iso8601withFractionsDecoder

    let exampleJSON = """
    {
      "id": 25647,
      "category": 3281,
      "name": {
        "en": "T-Shirt"
      },
      "internal_name": null,
      "active": true,
      "sales_channels": [
        "web",
        "pretixpos",
        "resellers"
      ],
      "description": null,
      "default_price": "25.00",
      "free_price": false,
      "tax_rate": "19.00",
      "tax_rule": 12107,
      "admission": false,
      "position": 0,
      "picture": null,
      "available_from": null,
      "available_until": null,
      "require_voucher": false,
      "hide_without_voucher": false,
      "allow_cancel": false,
      "require_bundling": false,
      "min_per_order": null,
      "max_per_order": null,
      "checkin_attention": false,
      "has_variations": true,
      "variations": [
        {
          "id": 6423,
          "value": {
            "de": "S"
          },
          "active": true,
          "description": {},
          "position": 0,
          "default_price": null,
          "price": "25.00"
        },
        {
          "id": 6424,
          "value": {
            "de": "M"
          },
          "active": true,
          "description": {},
          "position": 1,
          "default_price": null,
          "price": "25.00"
        }
      ],
      "addons": [],
      "bundles": [],
      "original_price": null,
      "require_approval": false,
      "generate_tickets": null
    }
    """.data(using: .utf8)!

    let exampleObject = Item(
        identifier: 25647,
        name: MultiLingualString.english("T-Shirt"),
        internalName: nil,
        defaultPrice: "25.00",
        categoryIdentifier: 3281,
        active: true,
        description: nil,
        freePrice: false,
        taxRate: "19.00",
        taxRuleIdentifier: 12107,
        admission: false,
        position: 0,
        picture: nil,
        salesChannels: ["web", "pretixpos", "resellers"],
        availableFrom: nil,
        availableUntil: nil,
        requireVoucher: false,
        hideWithoutVoucher: false,
        allowCancel: false,
        minPerOrder: nil,
        maxPerOrder: nil,
        checkInAttention: false,
        originalPrice: nil,
        requireApproval: false,
        requireBundling: false,
        generateTickets: nil,
        hasVariations: true,
        variations: [
            ItemVariation(identifier: 6423, name: MultiLingualString.german("S"),
                          defaultPrice: nil, price: "25.00", active: true, description: MultiLingualString.empty(), position: 0),
            ItemVariation(identifier: 6424, name: MultiLingualString.german("M"),
                          defaultPrice: nil, price: "25.00", active: true, description: MultiLingualString.empty(), position: 1)
        ],
        addons: [],
        bundles: []
    )

    func testParsingAll() {
        XCTAssertNoThrow(try jsonDecoder.decode(Item.self, from: exampleJSON))
        let parsedInstance = try? jsonDecoder.decode(Item.self, from: exampleJSON)
        XCTAssertEqual(parsedInstance, exampleObject)
    }
}
