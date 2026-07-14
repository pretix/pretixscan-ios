//
//  FMDBReusableMediumTests.swift
//  PretixScanTests
//
//  Created by Konstantin Kostov on 14/07/2026.
//  Copyright © 2026 rami.io. All rights reserved.
//

import XCTest
@testable import pretixSCAN

class FMDBReusableMediumTests: XCTestCase {
    private var dataStore: FMDBDataStore!
    private var event: Event!

    private let orderPosition18697 = OrderPosition(
        identifier: 18697, orderCode: "MED1", orderStatus: .paid, order: nil, positionid: 1, itemIdentifier: 1,
        item: nil, variation: nil, price: "10.00", attendeeName: nil, attendeeEmail: nil,
        secret: "secret18697", subEvent: nil, pseudonymizationId: "PSEUDO18697",
        checkins: [], answers: [], seat: nil, requiresAttention: nil, blocked: nil, validFrom: nil, validUntil: nil)

    private let orderPosition18698 = OrderPosition(
        identifier: 18698, orderCode: "MED1", orderStatus: .paid, order: nil, positionid: 2, itemIdentifier: 1,
        item: nil, variation: nil, price: "10.00", attendeeName: nil, attendeeEmail: nil,
        secret: "secret18698", subEvent: nil, pseudonymizationId: "PSEUDO18698",
        checkins: [], answers: [], seat: nil, requiresAttention: nil, blocked: nil, validFrom: nil, validUntil: nil)

    private let orderPosition18699 = OrderPosition(
        identifier: 18699, orderCode: "MED2", orderStatus: .paid, order: nil, positionid: 1, itemIdentifier: 1,
        item: nil, variation: nil, price: "10.00", attendeeName: nil, attendeeEmail: nil,
        secret: "secret18699", subEvent: nil, pseudonymizationId: "PSEUDO18699",
        checkins: [], answers: [], seat: nil, requiresAttention: nil, blocked: nil, validFrom: nil, validUntil: nil)

    override func setUp() {
        super.setUp()
        dataStore = FMDBDataStore()
        event = Event(name: MultiLingualString.english("Reusable Medium Test Event"), slug: "reusablemediumtest-\(UUID().uuidString)",
                      dateFrom: Date(), dateTo: Date(), dateAdmission: Date(), hasSubEvents: false, validKeys: nil,
                      timezone: Calendar.current.timeZone.identifier)

        dataStore.store([orderPosition18697, orderPosition18698, orderPosition18699], for: event)
    }

    override func tearDown() {
        dataStore.destroyDataStore(for: event, recreate: false)
        dataStore = nil
        event = nil
        super.tearDown()
    }

    func testStoreAndRetrieveMediumWithLinkedPositions() {
        let medium = ReusableMedium(identifier: 501, type: "barcode", mediumIdentifier: "AAA111", active: true,
                                    expires: nil, customer: nil, linkedOrderPositions: [18697, 18698], linkedGiftCard: nil)
        dataStore.store([medium], for: event)

        let retrievedMedium = dataStore.getReusableMedium(identifier: "AAA111", type: "barcode", in: event)
        XCTAssertEqual(retrievedMedium, medium)
        XCTAssertEqual(retrievedMedium?.type, "barcode")
        XCTAssertEqual(retrievedMedium?.active, true)
        XCTAssertNil(retrievedMedium?.expires)
        XCTAssertNil(retrievedMedium?.customer)
        XCTAssertEqual(retrievedMedium?.linkedOrderPositions, [18697, 18698])

        let linkedPositions = dataStore.getOrderPositions(linkedToMedium: medium, in: event)
        XCTAssertEqual(Set(linkedPositions.map { $0.identifier }), Set([18697, 18698]))
    }

    func testStoreAndRetrieveMediumRoundTripsAllFields() {
        let created = Formatter.iso8601.date(from: "2026-06-01T08:00:00.000Z")!
        let expires = Formatter.iso8601.date(from: "2026-12-31T23:59:59.000Z")!
        let medium = ReusableMedium(identifier: 503, type: "barcode", mediumIdentifier: "CCC333", active: false,
                                    expires: expires, created: created, customer: "customer-42",
                                    linkedOrderPositions: [18699], linkedGiftCard: nil)
        dataStore.store([medium], for: event)

        let retrievedMedium = dataStore.getReusableMedium(identifier: "CCC333", type: "barcode", in: event)
        XCTAssertEqual(retrievedMedium?.type, "barcode")
        XCTAssertEqual(retrievedMedium?.active, false)
        XCTAssertEqual(retrievedMedium?.expires, expires)
        XCTAssertEqual(retrievedMedium?.created, created)
        XCTAssertEqual(retrievedMedium?.customer, "customer-42")
        XCTAssertEqual(retrievedMedium?.linkedOrderPositions, [18699])
    }

    func testUnknownMediumReturnsNil() {
        XCTAssertNil(dataStore.getReusableMedium(identifier: "does-not-exist", type: "barcode", in: event))
    }

    func testGetReusableMediumForCheckInFindsMediumWithLinkedPositions() {
        let medium = ReusableMedium(identifier: 504, type: "barcode", mediumIdentifier: "DDD444", active: true,
                                    expires: nil, customer: nil, linkedOrderPositions: [18697], linkedGiftCard: nil)
        dataStore.store([medium], for: event)

        let retrievedMedium = dataStore.getReusableMediumForCheckIn(identifier: "DDD444", type: "barcode", in: event)
        XCTAssertEqual(retrievedMedium, medium)
    }

    func testGetReusableMediumForCheckInReturnsNilForMediumWithoutLinkedPositions() {
        let medium = ReusableMedium(identifier: 505, type: "barcode", mediumIdentifier: "EEE555", active: true,
                                    expires: nil, customer: nil, linkedOrderPositions: [], linkedGiftCard: nil)
        dataStore.store([medium], for: event)

        XCTAssertNotNil(dataStore.getReusableMedium(identifier: "EEE555", type: "barcode", in: event))
        XCTAssertNil(dataStore.getReusableMediumForCheckIn(identifier: "EEE555", type: "barcode", in: event))
    }

    func testGetReusableMediumForCheckInReturnsNilForUnknownMedium() {
        XCTAssertNil(dataStore.getReusableMediumForCheckIn(identifier: "does-not-exist", type: "barcode", in: event))
    }

    func testRestoringMediumReplacesLinkedPositions() {
        let medium = ReusableMedium(identifier: 502, type: "barcode", mediumIdentifier: "BBB222", active: true,
                                    expires: nil, customer: nil, linkedOrderPositions: [18697, 18698], linkedGiftCard: nil)
        dataStore.store([medium], for: event)
        XCTAssertEqual(Set(dataStore.getOrderPositions(linkedToMedium: medium, in: event).map { $0.identifier }), Set([18697, 18698]))

        let updatedMedium = ReusableMedium(identifier: 502, type: "barcode", mediumIdentifier: "BBB222", active: false,
                                           expires: nil, customer: nil, linkedOrderPositions: [18699], linkedGiftCard: nil)
        dataStore.store([updatedMedium], for: event)

        let retrievedMedium = dataStore.getReusableMedium(identifier: "BBB222", type: "barcode", in: event)
        XCTAssertEqual(retrievedMedium?.active, false)

        let linkedPositions = dataStore.getOrderPositions(linkedToMedium: updatedMedium, in: event)
        XCTAssertEqual(linkedPositions.map { $0.identifier }, [18699])
    }
}
