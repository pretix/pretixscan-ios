//
//  OrderTests.swift
//  PretixScanTests
//
//  Created by Daniel Jilg on 08.04.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import XCTest
@testable import pretixSCAN

class OrderTests: XCTestCase {
    private let jsonDecoder = JSONDecoder.iso8601withFractionsDecoder

    let exampleJSON = """
    {
      "code": "YFVJA",
      "status": "p",
      "testmode": false,
      "secret": "24p7qnkvapqplr57",
      "email": null,
      "locale": "en",
      "payment_date": "2019-03-25",
      "payment_provider": "manual",
      "fees": [],
      "total": "250.00",
      "comment": "",
      "invoice_address": null,
      "positions": [],
      "downloads": [],
      "refunds": [],
      "require_approval": false,
      "sales_channel": "resellers"
    }
    """.data(using: .utf8)!

    let exampleObject = Order(
        code: "YFVJA", status: .paid, secret: "24p7qnkvapqplr57", email: nil, locale: .english,
        salesChannel: "resellers", createdAt: nil, expiresAt: nil, lastModifiedAt: nil,
        total: "250.00", comment: "", checkInAttention: nil, positions: [], requireApproval: false)

    func testParsingAll() {
        XCTAssertNoThrow(try jsonDecoder.decode(Order.self, from: exampleJSON))
        let parsedInstance = try? jsonDecoder.decode(Order.self, from: exampleJSON)
        XCTAssertEqual(parsedInstance, exampleObject)
    }
}
