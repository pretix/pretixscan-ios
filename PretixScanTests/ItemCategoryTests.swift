//
//  ItemCategoryTests.swift
//  PretixScanTests
//
//  Created by Daniel Jilg on 09.04.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import XCTest
@testable import pretixSCAN

class ItemCategoryTests: XCTestCase {
    private let jsonDecoder = JSONDecoder.iso8601withFractionsDecoder

    let exampleJSON = """
    {
      "id": 3280,
      "name": {
        "en": "Tickets"
      },
      "internal_name": null,
      "description": {},
      "position": 0,
      "is_addon": false
    }
    """.data(using: .utf8)!

    let exampleObject = ItemCategory(identifier: 3280, name: MultiLingualString.english("Tickets"),
                                     internalName: nil, description: MultiLingualString(), position: 0, isAddon: false)

    func testParsingAll() {
        XCTAssertNoThrow(try jsonDecoder.decode(ItemCategory.self, from: exampleJSON))
        let parsedInstance = try? jsonDecoder.decode(ItemCategory.self, from: exampleJSON)
        XCTAssertEqual(parsedInstance, exampleObject)
    }
}
