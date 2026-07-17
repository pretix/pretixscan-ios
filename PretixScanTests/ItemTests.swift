//
//  ItemTests.swift
//  PretixScanTests
//
//  Created by Daniel Jilg on 09.04.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import XCTest
@testable import pretixSCAN

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
        checkInText: nil,
        hasVariations: true,
        variations: [
            ItemVariation(identifier: 6423, name: MultiLingualString.german("S"),
                          defaultPrice: nil, price: "25.00", active: true, description: MultiLingualString(), position: 0, checkInAttention: nil, checkInText: nil),
            ItemVariation(identifier: 6424, name: MultiLingualString.german("M"),
                          defaultPrice: nil, price: "25.00", active: true, description: MultiLingualString(), position: 1, checkInAttention: nil, checkInText: nil)
        ],
        addons: [],
        bundles: [],
        mediaPolicy: .none,
        mediaType: .none
    )

    func testParsingAll() {
        XCTAssertNoThrow(try jsonDecoder.decode(Item.self, from: exampleJSON))
        let parsedInstance = try? jsonDecoder.decode(Item.self, from: exampleJSON)
        XCTAssertEqual(parsedInstance, exampleObject)
    }
    
    func testSerializeItemVariationRequiresAttention() {
        let jsonData = testFileContents("item3")
        let item = try! jsonDecoder.decode(Item.self, from: jsonData)
        XCTAssertEqual(item.hasVariations, true)
        XCTAssertEqual(item.variations[4].checkInAttention, true)
    }

    func testMediaPolicyAndTypeAbsentDefaultToNone() {
        let parsedInstance = try! jsonDecoder.decode(Item.self, from: exampleJSON)
        XCTAssertEqual(parsedInstance.mediaPolicy, .none)
        XCTAssertEqual(parsedInstance.mediaType, .none)
    }

    func testMediaPolicyValidValues() {
        let cases: [(String, MediaPolicy)] = [
            ("none", .none),
            ("new", .new),
            ("reuse", .reuse),
            ("reuse_or_new", .reuseOrNew),
            ("append", .append),
            ("append_or_new", .appendOrNew)
        ]
        for (rawValue, expected) in cases {
            let item = try! jsonDecoder.decode(Item.self, from: itemJSON(mediaPolicy: rawValue))
            XCTAssertEqual(item.mediaPolicy, expected, "media_policy \(rawValue)")
        }
    }

    func testMediaTypeValidValues() {
        let cases: [(String, ReusableMediaType)] = [
            ("none", .none),
            ("barcode", .barcode),
            ("nfc_uid", .nfcUid),
            ("nfc_mf0aes", .nfcMf0aes),
            ("unsupported", .unsupported)
        ]
        for (rawValue, expected) in cases {
            let item = try! jsonDecoder.decode(Item.self, from: itemJSON(mediaType: rawValue))
            XCTAssertEqual(item.mediaType, expected, "media_type \(rawValue)")
        }
    }

    func testUnknownMediaPolicyDefaultsToUnsupportedAndGates() {
        let item = try! jsonDecoder.decode(Item.self, from: itemJSON(mediaPolicy: "some_future_policy"))
        XCTAssertEqual(item.mediaPolicy, .unsupported)
        XCTAssertNotEqual(item.mediaPolicy, .none)
    }

    func testUnknownMediaTypeDefaultsToUnsupported() {
        let item = try! jsonDecoder.decode(Item.self, from: itemJSON(mediaType: "some_future_type"))
        XCTAssertEqual(item.mediaType, .unsupported)
    }

    private func itemJSON(mediaPolicy: String? = nil, mediaType: String? = nil) -> Data {
        var json = String(data: exampleJSON, encoding: .utf8)!
        var extraFields = ""
        if let mediaPolicy {
            extraFields += ",\n\"media_policy\": \"\(mediaPolicy)\""
        }
        if let mediaType {
            extraFields += ",\n\"media_type\": \"\(mediaType)\""
        }
        let insertionIndex = json.index(json.lastIndex(of: "}")!, offsetBy: 0)
        json.insert(contentsOf: extraFields, at: insertionIndex)
        return json.data(using: .utf8)!
    }
}
