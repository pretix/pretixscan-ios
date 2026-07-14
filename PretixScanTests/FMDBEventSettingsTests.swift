//
//  FMDBEventSettingsTests.swift
//  PretixScanTests
//
//  Created by Konstantin Kostov on 15/07/2026.
//  Copyright © 2026 rami.io. All rights reserved.
//

import XCTest
@testable import pretixSCAN

class FMDBEventSettingsTests: XCTestCase {
    private var dataStore: FMDBDataStore!
    private var event: Event!

    override func setUp() {
        super.setUp()
        dataStore = FMDBDataStore()
        event = Event(name: MultiLingualString.english("Event Settings Test Event"), slug: "eventsettingstest-\(UUID().uuidString)",
                      dateFrom: Date(), dateTo: Date(), dateAdmission: Date(), hasSubEvents: false, validKeys: nil,
                      timezone: Calendar.current.timeZone.identifier)
    }

    override func tearDown() {
        dataStore.destroyDataStore(for: event, recreate: false)
        dataStore = nil
        event = nil
        super.tearDown()
    }

    func testReturnsNilWhenNeverSynced() {
        XCTAssertNil(dataStore.getEventSettings(in: event))
    }

    func testStoreAndRetrieveSettings() {
        let settings = EventSettings(reusableMediaUsageEnforced: true)
        dataStore.store([settings], for: event)

        let retrieved = dataStore.getEventSettings(in: event)
        XCTAssertEqual(retrieved?.reusableMediaUsageEnforced, true)
    }

    func testStoringNewSettingsReplacesThePreviousValue() {
        dataStore.store([EventSettings(reusableMediaUsageEnforced: true)], for: event)
        dataStore.store([EventSettings(reusableMediaUsageEnforced: false)], for: event)

        let retrieved = dataStore.getEventSettings(in: event)
        XCTAssertEqual(retrieved?.reusableMediaUsageEnforced, false)
    }
}
