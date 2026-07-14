//
//  OfflineTicketValidatorReusableMediumTests.swift
//  PretixScanTests
//
//  Created by Konstantin Kostov on 15/07/2026.
//  Copyright © 2026 rami.io. All rights reserved.
//

import XCTest
@testable import pretixSCAN

class OfflineTicketValidatorReusableMediumTests: XCTestCase {
    private var dataStore: FMDBDataStore!
    private var event: Event!
    private var checkInList: CheckInList!
    private var item: Item!
    private var configStore: FakeConfigStore!
    private var sut: OfflineTicketValidator!

    override func setUp() {
        super.setUp()
        dataStore = FMDBDataStore()
        event = Event(name: MultiLingualString.english("Reusable Medium Redeem Test"), slug: "rmredeemtest-\(UUID().uuidString)",
                      dateFrom: Date(), dateTo: Date(), dateAdmission: Date(), hasSubEvents: false, validKeys: nil,
                      timezone: Calendar.current.timeZone.identifier)
        checkInList = try! JSONDecoder.iso8601withFractionsDecoder.decode(CheckInList.self, from: testFileContents("list1", "json"))
        item = Item(identifier: 1, name: MultiLingualString.english("Regular ticket"), internalName: nil, defaultPrice: "23.00",
                   categoryIdentifier: nil, active: true, description: nil, freePrice: false, taxRate: "0.00", taxRuleIdentifier: nil,
                   admission: true, position: 0, picture: nil, salesChannels: ["web"], availableFrom: nil, availableUntil: nil,
                   requireVoucher: false, hideWithoutVoucher: false, allowCancel: true, minPerOrder: nil, maxPerOrder: nil,
                   checkInAttention: false, originalPrice: nil, requireApproval: false, requireBundling: false, generateTickets: nil,
                   checkInText: nil, hasVariations: false, variations: [], addons: [], bundles: [],
                   mediaPolicy: .none, mediaType: .none)
        dataStore.store([item], for: event)
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
        item = nil
        configStore = nil
        sut = nil
        super.tearDown()
    }

    private func makePosition(identifier: Identifier, secret: String, validFrom: Date? = nil, validUntil: Date? = nil) -> OrderPosition {
        OrderPosition(
            identifier: identifier, orderCode: "W0JKM", orderStatus: .paid, order: nil, positionid: identifier, itemIdentifier: 1,
            item: nil, variation: nil, price: "23.00", attendeeName: nil, attendeeEmail: nil,
            secret: secret, subEvent: nil, pseudonymizationId: "PSEUDO\(identifier)",
            checkins: [], answers: [], seat: nil, requiresAttention: nil, blocked: nil, validFrom: validFrom, validUntil: validUntil)
    }

    private func redeem(_ secret: String, in list: CheckInList? = nil, as type: String = "entry", nowDate: Date = Date()) -> RedemptionResponse? {
        var result: RedemptionResponse?
        let expectation = expectation(description: "Redeem")
        sut.redeem(list ?? checkInList, event, secret, force: false, ignoreUnpaid: false, answers: nil, as: type, nowDate: nowDate, completionHandler: { response, _ in
            result = response
            expectation.fulfill()
        })
        waitForExpectations(timeout: 5, handler: nil)
        return result
    }

    func testMediumNotActiveIsInvalid() {
        let position = makePosition(identifier: 5555, secret: "secret5555")
        dataStore.store([position], for: event)
        let medium = ReusableMedium(identifier: 5555, type: "barcode", mediumIdentifier: "5555", active: false,
                                    expires: nil, customer: nil, linkedOrderPositions: [5555], linkedGiftCard: nil)
        dataStore.store([medium], for: event)

        let response = redeem("5555")

        XCTAssertEqual(response?.status, .error)
        XCTAssertEqual(response?.errorReason, .invalid)
        XCTAssertNil(response?.position)
    }

    func testMediumExpiredIsInvalid() {
        let position = makePosition(identifier: 6666, secret: "secret6666")
        dataStore.store([position], for: event)
        let expires = Date().addingTimeInterval(-3600)
        let medium = ReusableMedium(identifier: 6666, type: "barcode", mediumIdentifier: "6666", active: true,
                                    expires: expires, customer: nil, linkedOrderPositions: [6666], linkedGiftCard: nil)
        dataStore.store([medium], for: event)

        let response = redeem("6666")

        XCTAssertEqual(response?.status, .error)
        XCTAssertEqual(response?.errorReason, .invalid)
        XCTAssertNil(response?.position)
    }

    func testTwoTicketsOverlappingIsAmbiguous() {
        let positionA = makePosition(identifier: 1111, secret: "secret1111a")
        let positionB = makePosition(identifier: 1112, secret: "secret1111b")
        dataStore.store([positionA, positionB], for: event)
        let medium = ReusableMedium(identifier: 1111, type: "barcode", mediumIdentifier: "1111", active: true,
                                    expires: nil, customer: nil, linkedOrderPositions: [1111, 1112], linkedGiftCard: nil)
        dataStore.store([medium], for: event)

        let response = redeem("1111")

        XCTAssertEqual(response?.status, .error)
        XCTAssertEqual(response?.errorReason, .ambiguous)
    }

    /// Uses two independent mediums, each redeemed once, so a redemption's side effects on one
    /// medium's positions can't influence the read of the other medium's positions.
    func testTwoTicketsNonOverlappingPicksTheCurrentlyValidOne() {
        let now = Date()

        let positionA = makePosition(identifier: 3333, secret: "secret3333a",
                                     validFrom: now.addingTimeInterval(-3600), validUntil: now.addingTimeInterval(3600))
        let positionB = makePosition(identifier: 3334, secret: "secret3333b",
                                     validFrom: now.addingTimeInterval(7200), validUntil: now.addingTimeInterval(10800))
        dataStore.store([positionA, positionB], for: event)
        let mediumEarly = ReusableMedium(identifier: 3333, type: "barcode", mediumIdentifier: "3333", active: true,
                                         expires: nil, customer: nil, linkedOrderPositions: [3333, 3334], linkedGiftCard: nil)
        dataStore.store([mediumEarly], for: event)

        let response = redeem("3333", nowDate: now)

        XCTAssertEqual(response?.status, .redeemed)
        XCTAssertEqual(response?.position?.identifier, 3333)

        let positionC = makePosition(identifier: 3335, secret: "secret3335a",
                                     validFrom: now.addingTimeInterval(-10800), validUntil: now.addingTimeInterval(-7200))
        let positionD = makePosition(identifier: 3336, secret: "secret3335b",
                                     validFrom: now.addingTimeInterval(-1800), validUntil: now.addingTimeInterval(1800))
        dataStore.store([positionC, positionD], for: event)
        let mediumLate = ReusableMedium(identifier: 3335, type: "barcode", mediumIdentifier: "3335", active: true,
                                        expires: nil, customer: nil, linkedOrderPositions: [3335, 3336], linkedGiftCard: nil)
        dataStore.store([mediumLate], for: event)

        let response2 = redeem("3335", nowDate: now)

        XCTAssertEqual(response2?.status, .redeemed)
        XCTAssertEqual(response2?.position?.identifier, 3336)
    }

    func testGapBetweenWindowsUsesNearestFutureThenInvalidTime() {
        let now = Date()
        let positionA = makePosition(identifier: 7776, secret: "secret7776",
                                     validFrom: now.addingTimeInterval(-7200), validUntil: now.addingTimeInterval(-3600))
        let positionB = makePosition(identifier: 7777, secret: "secret7777",
                                     validFrom: now.addingTimeInterval(3600), validUntil: now.addingTimeInterval(7200))
        dataStore.store([positionA, positionB], for: event)
        let medium = ReusableMedium(identifier: 7777, type: "barcode", mediumIdentifier: "7777", active: true,
                                    expires: nil, customer: nil, linkedOrderPositions: [7776, 7777], linkedGiftCard: nil)
        dataStore.store([medium], for: event)

        let gapResponse = redeem("7777", nowDate: now)
        XCTAssertEqual(gapResponse?.status, .error)
        XCTAssertEqual(gapResponse?.errorReason, .invalidTime)
        XCTAssertEqual(gapResponse?.position?.identifier, 7777)

        let afterAllResponse = redeem("7777", nowDate: now.addingTimeInterval(10800))
        XCTAssertEqual(afterAllResponse?.status, .error)
        XCTAssertEqual(afterAllResponse?.errorReason, .invalidTime)
        XCTAssertEqual(afterAllResponse?.position?.identifier, 7777)
    }

    func testExitScanInGapBetweenWindowsIsInvalidTimeNotRedeemed() {
        let now = Date()
        let positionA = makePosition(identifier: 7778, secret: "secret7778",
                                     validFrom: now.addingTimeInterval(-7200), validUntil: now.addingTimeInterval(-3600))
        let positionB = makePosition(identifier: 7779, secret: "secret7779",
                                     validFrom: now.addingTimeInterval(3600), validUntil: now.addingTimeInterval(7200))
        dataStore.store([positionA, positionB], for: event)
        let medium = ReusableMedium(identifier: 7779, type: "barcode", mediumIdentifier: "7779", active: true,
                                    expires: nil, customer: nil, linkedOrderPositions: [7778, 7779], linkedGiftCard: nil)
        dataStore.store([medium], for: event)

        let response = redeem("7779", as: "exit", nowDate: now)

        XCTAssertEqual(response?.status, .error)
        XCTAssertEqual(response?.errorReason, .invalidTime)
        XCTAssertEqual(response?.position?.identifier, 7779)
    }

    func testMediumWithoutLinkedPositionsFallsThroughToDataless() {
        let medium = ReusableMedium(identifier: 8888, type: "barcode", mediumIdentifier: "8888", active: true,
                                    expires: nil, customer: nil, linkedOrderPositions: [], linkedGiftCard: nil)
        dataStore.store([medium], for: event)

        let response = redeem("8888")

        XCTAssertEqual(response?.status, .error)
        XCTAssertEqual(response?.errorReason, .invalid)
    }

    func testUnknownSecretFallsThroughToDataless() {
        let response = redeem("not-a-known-secret-or-medium")

        XCTAssertEqual(response?.status, .error)
        XCTAssertEqual(response?.errorReason, .invalid)
    }

    func testSecondRedeemNilBecauseOfSubEventMismatchIsInvalid() {
        let position = makePosition(identifier: 9999, secret: "secret9999")
        dataStore.store([position], for: event)
        let medium = ReusableMedium(identifier: 9999, type: "barcode", mediumIdentifier: "9999", active: true,
                                    expires: nil, customer: nil, linkedOrderPositions: [9999], linkedGiftCard: nil)
        dataStore.store([medium], for: event)

        let listWithSubEvent = try! JSONDecoder.iso8601withFractionsDecoder.decode(CheckInList.self, from: testFileContents("list4", "json"))
        configStore.checkInList = listWithSubEvent

        let response = redeem("9999", in: listWithSubEvent)

        XCTAssertEqual(response?.status, .error)
        XCTAssertEqual(response?.errorReason, .invalid)
        XCTAssertNil(response?.position)
    }
}

final class FakeFeedbackGenerator: FeedbackGenerator {
    func announce(_ type: FeedbackType) {}
    func announce(redemptionResponse: RedemptionResponse?, _ error: Error?, _ exitMode: Bool) {}
    func setMode(_ mode: FeedbackMode) -> Self { self }
    func setPlaySounds(_ playSounds: Bool) -> Self { self }
}

final class FakeConfigStore: ConfigStore {
    var dataStore: DataStore?
    var event: Event?
    var checkInList: CheckInList?
    var apiClient: APIClient?
    var ticketValidator: TicketValidator?
    lazy var syncManager: SyncManager = SyncManager(configStore: self)
    var feedbackGenerator: FeedbackGenerator = FakeFeedbackGenerator()

    var welcomeScreenIsConfirmed: Bool = true
    var apiBaseURL: URL?
    var asyncModeEnabled: Bool = true
    var shouldAutoSync: Bool = false
    var shouldDownloadOrders: Bool = false
    var shouldPlaySounds: Bool = false
    var useDeviceCamera: Bool = false
    var preferFrontCamera: Bool = false
    var scanMode: String = "entry"
    var publishedSoftwareVersion: String?
    var enableSearch: Bool = true
    var deviceName: String?
    var organizerSlug: String?
    var deviceID: Int?
    var deviceUniqueSerial: String?
    var securityProfile: PXSecurityProfile = .full
    var isDeviceInitialized: Bool = true
    var allManagedEvents: [Event] = []
    var knownPretixVersion: Int?
    var deviceKnownGateId: Int?
    var deviceKnownGateName: String?

    func factoryReset() {}

    func set(event: Event, checkInList: CheckInList) {
        self.event = event
        self.checkInList = checkInList
    }

    func applySecurityDefaults() {}
    func valueChanged(_ value: ConfigStoreValue?) {}
    func updateAndApplyCredentials(deviceInit: DeviceInitializationResponse) {}
}
