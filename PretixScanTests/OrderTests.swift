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
      "locale": "unk-unknown_language_shouldnt_break_parsing",
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
        code: "YFVJA", status: .paid, secret: "24p7qnkvapqplr57", email: nil,
        salesChannel: "resellers", createdAt: nil, expiresAt: nil, lastModifiedAt: nil,
        total: "250.00", comment: "", checkInAttention: nil, positions: [], requireApproval: false, validIfPending: nil, checkInText: nil)

    func testParsingAll() {
        XCTAssertNoThrow(try jsonDecoder.decode(Order.self, from: exampleJSON))
        let parsedInstance = try? jsonDecoder.decode(Order.self, from: exampleJSON)
        XCTAssertEqual(parsedInstance, exampleObject)
    }

    func testGetOrderCheckInsMatchesPositionSecretExactly() {
        let dataStore = FMDBDataStore()
        let event = Event(name: MultiLingualString.english("Order Secret Lookup Event"), slug: "ordersecretlookup-\(UUID().uuidString)",
                          dateFrom: Date(), dateTo: Date(), dateAdmission: Date(), hasSubEvents: false, validKeys: nil,
                          timezone: Calendar.current.timeZone.identifier)
        defer { dataStore.destroyDataStore(for: event, recreate: false) }
        let listId: Identifier = 1

        func order(code: String, positionId: Identifier, positionSecret: String, checkins: [CheckIn]) -> Order {
            let position = OrderPosition(
                identifier: positionId, orderCode: code, orderStatus: .paid, order: nil, positionid: 1, itemIdentifier: 1,
                item: nil, variation: nil, price: "10.00", attendeeName: nil, attendeeEmail: nil,
                secret: positionSecret, subEvent: nil, pseudonymizationId: "PSEUDO\(positionId)",
                checkins: checkins, answers: [], seat: nil, requiresAttention: nil, blocked: nil, validFrom: nil, validUntil: nil)
            return Order(
                code: code, status: .paid, secret: "ordersecret\(positionId)", email: nil,
                salesChannel: "web", createdAt: nil, expiresAt: nil, lastModifiedAt: nil,
                total: "10.00", comment: nil, checkInAttention: nil, positions: [position], requireApproval: false,
                validIfPending: nil, checkInText: nil)
        }

        let entry = CheckIn(listID: listId, date: Date().addingTimeInterval(-3600), type: "entry")
        dataStore.store([
            order(code: "QUOTE", positionId: 1, positionSecret: "it's%a_secret", checkins: [entry]),
            order(code: "UPPER", positionId: 2, positionSecret: "CASESECRET", checkins: []),
            order(code: "LOWER", positionId: 3, positionSecret: "casesecret", checkins: [entry])
        ], for: event)

        XCTAssertEqual(dataStore.getOrderCheckIns("it's%a_secret", type: "entry", event, listId: listId).count, 1)
        XCTAssertEqual(dataStore.getOrderCheckIns("casesecret", type: "entry", event, listId: listId).count, 1)
        XCTAssertEqual(dataStore.getOrderCheckIns("CASESECRET", type: "entry", event, listId: listId).count, 0)
        XCTAssertEqual(dataStore.getOrderCheckIns("case_ecret", type: "entry", event, listId: listId).count, 0)
    }
}
