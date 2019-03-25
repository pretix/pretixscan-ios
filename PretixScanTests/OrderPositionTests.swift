//
//  OrderPositionTests.swift
//  PretixScanTests
//
//  Created by Daniel Jilg on 19.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import XCTest

class OrderPositionTests: XCTestCase {
    let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .fractionalISO8601
        return jsonDecoder
    }()

    let exampleJSON = """
        {
      "id": 1842899,
      "order": "RDTBG",
      "positionid": 1,
      "item": 25643,
      "variation": null,
      "price": "250.00",
      "attendee_name": "Daniel Jilg",
      "attendee_name_parts": {
        "_scheme": "full",
        "full_name": "Daniel Jilg"
      },
      "attendee_email": null,
      "voucher": null,
      "tax_rate": "19.00",
      "tax_value": "39.92",
      "secret": "xmwtyuq5rf3794hwudf7smr6zgmbez9y",
      "addon_to": null,
      "subevent": null,
      "checkins": [],
      "downloads": [
        {
          "output": "pdf",
          "url": "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/orderpositions/1842899/download/pdf/"
        },
        {
          "output": "passbook",
          "url": "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/orderpositions/1842899/download/passbook/"
        }
      ],
      "answers": [],
      "tax_rule": 12107,
      "pseudonymization_id": "DAC7ULNMUB"
    }
    """.data(using: .utf8)!

    let exampleObject = OrderPosition(
        identifier: 1842899, order: "RDTBG", positionid: 1, item: 25643, variation: nil, price: "250.00",
        attendeeName: "Daniel Jilg", attendeeEmail: nil, secret: "xmwtyuq5rf3794hwudf7smr6zgmbez9y",
        pseudonymizationId: "DAC7ULNMUB", checkins: []
    )

    func testParsingAll() {
        XCTAssertNoThrow(try jsonDecoder.decode(OrderPosition.self, from: exampleJSON))
        let parsedInstance = try? jsonDecoder.decode(OrderPosition.self, from: exampleJSON)
        XCTAssertEqual(parsedInstance, exampleObject)
    }
}
