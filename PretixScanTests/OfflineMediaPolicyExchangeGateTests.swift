//
//  OfflineMediaPolicyExchangeGateTests.swift
//  PretixScanTests
//
//  Created by Konstantin Kostov on 15/07/2026.
//  Copyright © 2026 rami.io. All rights reserved.
//

import XCTest
@testable import pretixSCAN

class OfflineMediaPolicyExchangeGateTests: XCTestCase {
    private var dataStore: FMDBDataStore!
    private var event: Event!
    private var checkInList: CheckInList!
    private var configStore: FakeConfigStore!
    private var sut: OfflineTicketValidator!

    override func setUp() {
        super.setUp()
        dataStore = FMDBDataStore()
        event = Event(name: MultiLingualString.english("Exchange Gate Test"), slug: "exchangegatetest-\(UUID().uuidString)",
                      dateFrom: Date(), dateTo: Date(), dateAdmission: Date(), hasSubEvents: false, validKeys: nil,
                      timezone: Calendar.current.timeZone.identifier)
        checkInList = try! JSONDecoder.iso8601withFractionsDecoder.decode(CheckInList.self, from: testFileContents("list1", "json"))
        dataStore.store([Order.stubOrder(code: "W0JKM", status: .paid, secret: "ordersecret")], for: event)

        configStore = FakeConfigStore()
        configStore.dataStore = dataStore
        configStore.event = event
        configStore.checkInList = checkInList
        sut = OfflineTicketValidator(configStore: configStore)
    }

    override func tearDown() {
        dataStore.destroyDataStore(for: event, recreate: false)
        dataStore = nil
        event = nil
        checkInList = nil
        configStore = nil
        sut = nil
        super.tearDown()
    }

    private func makeItem(mediaPolicy: MediaPolicy, mediaType: ReusableMediaType) -> Item {
        Item(identifier: 1, name: MultiLingualString.english("Regular ticket"), internalName: nil, defaultPrice: "23.00",
            categoryIdentifier: nil, active: true, description: nil, freePrice: false, taxRate: "0.00", taxRuleIdentifier: nil,
            admission: true, position: 0, picture: nil, salesChannels: ["web"], availableFrom: nil, availableUntil: nil,
            requireVoucher: false, hideWithoutVoucher: false, allowCancel: true, minPerOrder: nil, maxPerOrder: nil,
            checkInAttention: false, originalPrice: nil, requireApproval: false, requireBundling: false, generateTickets: nil,
            checkInText: nil, hasVariations: false, variations: [], addons: [], bundles: [],
            mediaPolicy: mediaPolicy, mediaType: mediaType)
    }

    private func makePosition(identifier: Identifier, secret: String, checkins: [CheckIn] = []) -> OrderPosition {
        OrderPosition(
            identifier: identifier, orderCode: "W0JKM", orderStatus: .paid, order: nil, positionid: identifier, itemIdentifier: 1,
            item: nil, variation: nil, price: "23.00", attendeeName: nil, attendeeEmail: nil,
            secret: secret, subEvent: nil, pseudonymizationId: "PSEUDO\(identifier)",
            checkins: checkins, answers: [], seat: nil, requiresAttention: nil, blocked: nil, validFrom: nil, validUntil: nil)
    }

    private func redeem(_ secret: String, force: Bool = false) -> RedemptionResponse? {
        var result: RedemptionResponse?
        let expectation = expectation(description: "Redeem")
        sut.redeem(checkInList, event, secret, force: force, ignoreUnpaid: false, answers: nil, as: "entry", nowDate: Date(), completionHandler: { response, _ in
            result = response
            expectation.fulfill()
        })
        waitForExpectations(timeout: 5, handler: nil)
        return result
    }

    func testDirectScanWithoutLinkedMediumRefusesExchangeOffline() {
        let item = makeItem(mediaPolicy: .reuse, mediaType: .barcode)
        dataStore.store([item], for: event)
        let position = makePosition(identifier: 101, secret: "secret101")
        dataStore.store([position], for: event)

        let response = redeem("secret101")

        XCTAssertEqual(response?.status, .error)
        XCTAssertEqual(response?.errorReason, .exchangeOffline)
        XCTAssertFalse(response?.status == .redeemed)
    }

    func testDirectScanWithLinkedMediumAndEnforcementRefusesAlreadyExchanged() {
        let item = makeItem(mediaPolicy: .reuse, mediaType: .barcode)
        dataStore.store([item], for: event)
        let position = makePosition(identifier: 102, secret: "secret102")
        dataStore.store([position], for: event)
        let medium = ReusableMedium(identifier: 902, type: "barcode", mediumIdentifier: "MED902", active: true,
                                    expires: nil, customer: nil, linkedOrderPositions: [102], linkedGiftCard: nil)
        dataStore.store([medium], for: event)
        dataStore.store([EventSettings(reusableMediaUsageEnforced: true)], for: event)

        let response = redeem("secret102")

        XCTAssertEqual(response?.status, .error)
        XCTAssertEqual(response?.errorReason, .alreadyExchanged)
    }

    func testDirectScanWithLinkedMediumAndEnforcementOffProceedsNormally() {
        let item = makeItem(mediaPolicy: .reuse, mediaType: .barcode)
        dataStore.store([item], for: event)
        let position = makePosition(identifier: 103, secret: "secret103")
        dataStore.store([position], for: event)
        let medium = ReusableMedium(identifier: 903, type: "barcode", mediumIdentifier: "MED903", active: true,
                                    expires: nil, customer: nil, linkedOrderPositions: [103], linkedGiftCard: nil)
        dataStore.store([medium], for: event)
        dataStore.store([EventSettings(reusableMediaUsageEnforced: false)], for: event)

        let response = redeem("secret103")

        XCTAssertEqual(response?.status, .redeemed)
    }

    func testMediumResolvedScanBypassesGate() {
        let item = makeItem(mediaPolicy: .reuse, mediaType: .barcode)
        dataStore.store([item], for: event)
        let position = makePosition(identifier: 104, secret: "secret104")
        dataStore.store([position], for: event)
        let medium = ReusableMedium(identifier: 904, type: "barcode", mediumIdentifier: "MED904", active: true,
                                    expires: nil, customer: nil, linkedOrderPositions: [104], linkedGiftCard: nil)
        dataStore.store([medium], for: event)
        dataStore.store([EventSettings(reusableMediaUsageEnforced: true)], for: event)

        let response = redeem("MED904")

        XCTAssertEqual(response?.status, .redeemed)
        XCTAssertEqual(response?.position?.identifier, 104)
    }

    func testItemWithoutMediaPolicySkipsGate() {
        let item = makeItem(mediaPolicy: .none, mediaType: .none)
        dataStore.store([item], for: event)
        let position = makePosition(identifier: 105, secret: "secret105")
        dataStore.store([position], for: event)

        let response = redeem("secret105")

        XCTAssertEqual(response?.status, .redeemed)
    }

    func testAlreadyCheckedInUnexchangedTicketRefusesExchangeOfflineNotAlreadyRedeemed() {
        let item = makeItem(mediaPolicy: .reuse, mediaType: .barcode)
        dataStore.store([item], for: event)
        let existingCheckIn = CheckIn(listID: checkInList.identifier, date: Date().addingTimeInterval(-3600), type: "entry")
        let position = makePosition(identifier: 106, secret: "secret106", checkins: [existingCheckIn])
        dataStore.store([position], for: event)

        let response = redeem("secret106")

        XCTAssertEqual(response?.status, .error)
        XCTAssertEqual(response?.errorReason, .exchangeOffline)
        XCTAssertNotEqual(response?.errorReason, .alreadyRedeemed)
    }

    func testForcedScanWithoutLinkedMediumBypassesGate() {
        let item = makeItem(mediaPolicy: .reuse, mediaType: .barcode)
        dataStore.store([item], for: event)
        let position = makePosition(identifier: 108, secret: "secret108")
        dataStore.store([position], for: event)

        let response = redeem("secret108", force: true)

        XCTAssertEqual(response?.status, .redeemed)
    }

    func testForcedScanWithEnforcementOnBypassesGate() {
        let item = makeItem(mediaPolicy: .reuse, mediaType: .barcode)
        dataStore.store([item], for: event)
        let position = makePosition(identifier: 109, secret: "secret109")
        dataStore.store([position], for: event)
        let medium = ReusableMedium(identifier: 909, type: "barcode", mediumIdentifier: "MED909", active: true,
                                    expires: nil, customer: nil, linkedOrderPositions: [109], linkedGiftCard: nil)
        dataStore.store([medium], for: event)
        dataStore.store([EventSettings(reusableMediaUsageEnforced: true)], for: event)

        let response = redeem("secret109", force: true)

        XCTAssertEqual(response?.status, .redeemed)
    }

    func testMissingEventSettingsTreatedAsEnforcementFalse() {
        let item = makeItem(mediaPolicy: .reuse, mediaType: .barcode)
        dataStore.store([item], for: event)
        let position = makePosition(identifier: 107, secret: "secret107")
        dataStore.store([position], for: event)
        let medium = ReusableMedium(identifier: 907, type: "barcode", mediumIdentifier: "MED907", active: true,
                                    expires: nil, customer: nil, linkedOrderPositions: [107], linkedGiftCard: nil)
        dataStore.store([medium], for: event)

        let response = redeem("secret107")

        XCTAssertEqual(response?.status, .redeemed)
    }
}
