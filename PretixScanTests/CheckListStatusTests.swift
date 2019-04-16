//
//  CheckListStatusTests.swift
//  PretixScanTests
//
//  Created by Daniel Jilg on 27.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import XCTest

class CheckListStatusTests: XCTestCase {
    private let jsonDecoder = JSONDecoder.iso8601withFractionsDecoder

    let exampleJSON = """
        {
          "checkin_count": 17,
          "position_count": 42,
          "event": {
            "name": "Demo Conference"
          },
          "items": [
            {
              "name": "T-Shirt",
              "id": 1,
              "checkin_count": 1,
              "admission": false,
              "position_count": 1,
              "variations": [
                {
                  "value": "Red",
                  "id": 1,
                  "checkin_count": 1,
                  "position_count": 12
                },
                {
                  "value": "Blue",
                  "id": 2,
                  "checkin_count": 4,
                  "position_count": 8
                }
              ]
            },
            {
              "name": "Ticket",
              "id": 2,
              "checkin_count": 15,
              "admission": true,
              "position_count": 22,
              "variations": []
            }
          ]
        }
    """.data(using: .utf8)!

    let exampleObject = CheckInListStatus(checkinCount: 17, positionCount: 42, items: [
        CheckInListStatus.Item(
            name: "T-Shirt",
            identifier: 1,
            checkinCount: 1,
            admission: false,
            positionCount: 1,
            variations: [
                CheckInListStatus.Item.Variation(
                    value: "Red",
                    identifier: 1,
                    checkinCount: 1,
                    positionCount: 12
                ),
                CheckInListStatus.Item.Variation(
                    value: "Blue",
                    identifier: 2,
                    checkinCount: 4,
                    positionCount: 8
                )
            ]
        ),
        CheckInListStatus.Item(
            name: "Ticket",
            identifier: 2,
            checkinCount: 15,
            admission: true,
            positionCount: 22,
            variations: []
        )
    ])

    func testParsingAll() {
        XCTAssertNoThrow(try jsonDecoder.decode(CheckInListStatus.self, from: exampleJSON))
        let parsedInstance = try? jsonDecoder.decode(CheckInListStatus.self, from: exampleJSON)
        XCTAssertEqual(parsedInstance, exampleObject)
    }
}
