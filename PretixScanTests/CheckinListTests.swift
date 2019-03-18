//
//  CheckinListTests.swift
//  PretixScanTests
//
//  Created by Daniel Jilg on 18.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import XCTest

class CheckinListTests: XCTestCase {
    let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .iso8601
        return jsonDecoder
    }()

    let exampleJSONAllProducts = """
        {
          "id": 12159,
          "name": "Everyone",
          "all_products": true,
          "limit_products": [],
          "subevent": null,
          "checkin_count": 0,
          "position_count": 0,
          "include_pending": false
        }
    """.data(using: .utf8)!

    let exampleJSONLimitProducts = """
        {
          "id": 12160,
          "name": "Students only",
          "all_products": false,
          "limit_products": [
            25644
          ],
          "subevent": null,
          "checkin_count": 0,
          "position_count": 0,
          "include_pending": false
        }
    """.data(using: .utf8)!

    let exampleCheckInListAllProducts = CheckInList(
        identifier: 12159,
        name: "Everyone",
        allProducts: true,
        limitProducts: [],
        subEvent: nil,
        positionCount: 0,
        checkinCount: 0,
        includePending: false
    )

    let exampleCheckInListLimitProducts = CheckInList(
        identifier: 12160,
        name: "Students only",
        allProducts: false,
        limitProducts: [25644],
        subEvent: nil,
        positionCount: 0,
        checkinCount: 0,
        includePending: false
    )

    func testParsingAllProducts() {
        XCTAssertNoThrow(try jsonDecoder.decode(CheckInList.self, from: exampleJSONAllProducts))
        let parsedCheckInList = try? jsonDecoder.decode(CheckInList.self, from: exampleJSONAllProducts)
        XCTAssertEqual(parsedCheckInList, exampleCheckInListAllProducts)
    }

    func testParsingLimitedProducts() {
        XCTAssertNoThrow(try jsonDecoder.decode(CheckInList.self, from: exampleJSONLimitProducts))
        let parsedCheckInList = try? jsonDecoder.decode(CheckInList.self, from: exampleJSONLimitProducts)
        XCTAssertEqual(parsedCheckInList, exampleCheckInListLimitProducts)
    }
}
