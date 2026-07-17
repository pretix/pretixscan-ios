//
//  ReusableMediumPositionSelectorTests.swift
//  PretixScanTests
//
//  Created by Konstantin Kostov on 15/07/2026.
//  Copyright © 2026 rami.io. All rights reserved.
//

import XCTest
@testable import pretixSCAN

class ReusableMediumPositionSelectorTests: XCTestCase {
    private func position(identifier: Identifier, itemIdentifier: Identifier = 1, validFrom: Date? = nil, validUntil: Date? = nil) -> OrderPosition {
        OrderPosition(
            identifier: identifier, orderCode: "W0JKM", orderStatus: .paid, order: nil, positionid: identifier, itemIdentifier: itemIdentifier,
            item: nil, variation: nil, price: "10.00", attendeeName: nil, attendeeEmail: nil,
            secret: "secret\(identifier)", subEvent: nil, pseudonymizationId: "PSEUDO\(identifier)",
            checkins: [], answers: [], seat: nil, requiresAttention: nil, blocked: nil, validFrom: validFrom, validUntil: validUntil)
    }

    private func checkInList(allProducts: Bool = true, limitProducts: [Int]? = nil) -> CheckInList {
        CheckInList(identifier: 1, name: "All", allProducts: allProducts, limitProducts: limitProducts, subEvent: nil, positionCount: 0,
                    checkinCount: 0, includePending: true, allowEntryAfterExit: true, allowMultipleEntries: false, addonMatch: false)
    }

    func testEmptyPositionsReturnsNil() {
        XCTAssertNil(ReusableMediumPositionSelector.select(from: [], checkInList: checkInList()))
    }

    func testSingleCandidateIsUsedDirectly() {
        let position = position(identifier: 1)
        let result = ReusableMediumPositionSelector.select(from: [position], checkInList: checkInList())
        XCTAssertEqual(result, .position(position))
    }

    func testTwoCandidatesWithoutTimeWindowsAreAmbiguous() {
        let positionA = position(identifier: 1)
        let positionB = position(identifier: 2)
        let result = ReusableMediumPositionSelector.select(from: [positionA, positionB], checkInList: checkInList())
        XCTAssertEqual(result, .ambiguous(positionA))
    }

    func testTwoCandidatesWithOverlappingWindowsAreAmbiguous() {
        let now = Date()
        let positionA = position(identifier: 1, validFrom: now.addingTimeInterval(-3600), validUntil: now.addingTimeInterval(3600))
        let positionB = position(identifier: 2, validFrom: now.addingTimeInterval(-1800), validUntil: now.addingTimeInterval(1800))
        let result = ReusableMediumPositionSelector.select(from: [positionA, positionB], checkInList: checkInList(), nowDate: now)
        XCTAssertEqual(result, .ambiguous(positionA))
    }

    func testDisjointWindowsPicksTheCurrentlyValidOne() {
        let now = Date()
        let past = position(identifier: 1, validFrom: now.addingTimeInterval(-7200), validUntil: now.addingTimeInterval(-3600))
        let current = position(identifier: 2, validFrom: now.addingTimeInterval(-1800), validUntil: now.addingTimeInterval(1800))
        let future = position(identifier: 3, validFrom: now.addingTimeInterval(3600), validUntil: now.addingTimeInterval(7200))
        let result = ReusableMediumPositionSelector.select(from: [past, current, future], checkInList: checkInList(), nowDate: now)
        XCTAssertEqual(result, .position(current))
    }

    func testGapBetweenWindowsPicksNearestFutureAsFallbackPosition() {
        let now = Date()
        let earlier = position(identifier: 1, validFrom: now.addingTimeInterval(-7200), validUntil: now.addingTimeInterval(-3600))
        let nearFuture = position(identifier: 2, validFrom: now.addingTimeInterval(1800), validUntil: now.addingTimeInterval(3600))
        let farFuture = position(identifier: 3, validFrom: now.addingTimeInterval(7200), validUntil: now.addingTimeInterval(10800))
        let result = ReusableMediumPositionSelector.select(from: [earlier, nearFuture, farFuture], checkInList: checkInList(), nowDate: now)
        XCTAssertEqual(result, .position(nearFuture))
    }

    func testAfterAllWindowsPicksTheLatestPastCandidateAsFallbackPosition() {
        let now = Date()
        let earlier = position(identifier: 1, validFrom: now.addingTimeInterval(-14400), validUntil: now.addingTimeInterval(-10800))
        let later = position(identifier: 2, validFrom: now.addingTimeInterval(-7200), validUntil: now.addingTimeInterval(-3600))
        let result = ReusableMediumPositionSelector.select(from: [earlier, later], checkInList: checkInList(), nowDate: now)
        XCTAssertEqual(result, .position(later))
    }

    /// Latest-expiring past position wins regardless of input order.
    func testAfterAllWindowsPicksTheLatestPastCandidateRegardlessOfInputOrder() {
        let now = Date()
        let latest = position(identifier: 1, validFrom: now.addingTimeInterval(-7200), validUntil: now.addingTimeInterval(-3600))
        let earlier = position(identifier: 2, validFrom: now.addingTimeInterval(-14400), validUntil: now.addingTimeInterval(-10800))
        let result = ReusableMediumPositionSelector.select(from: [latest, earlier], checkInList: checkInList(), nowDate: now)
        XCTAssertEqual(result, .position(latest))
    }

    func testValidFromIsInclusive() {
        let now = Date()
        let startingNow = position(identifier: 1, validFrom: now, validUntil: now.addingTimeInterval(3600))
        let stillFuture = position(identifier: 2, validFrom: now.addingTimeInterval(7200), validUntil: now.addingTimeInterval(10800))
        let result = ReusableMediumPositionSelector.select(from: [startingNow, stillFuture], checkInList: checkInList(), nowDate: now)
        XCTAssertEqual(result, .position(startingNow))
    }

    func testProductFilterSelectsTheOnListPositionAmongMultipleValidOnes() {
        let now = Date()
        let onList = position(identifier: 1, itemIdentifier: 1, validFrom: now.addingTimeInterval(-3600), validUntil: now.addingTimeInterval(3600))
        let offList = position(identifier: 2, itemIdentifier: 2, validFrom: now.addingTimeInterval(-3600), validUntil: now.addingTimeInterval(3600))
        let list = checkInList(allProducts: false, limitProducts: [1])
        let result = ReusableMediumPositionSelector.select(from: [onList, offList], checkInList: list, nowDate: now)
        XCTAssertEqual(result, .position(onList))
    }

    /// `.ambiguous` carries positions[0] even when the product filter excludes it.
    func testAmbiguousCarriesTheFirstOriginalPositionEvenWhenExcludedByProductFilter() {
        let now = Date()
        let offListFirst = position(identifier: 1, itemIdentifier: 1, validFrom: now.addingTimeInterval(-3600), validUntil: now.addingTimeInterval(3600))
        let onListA = position(identifier: 2, itemIdentifier: 2, validFrom: now.addingTimeInterval(-3600), validUntil: now.addingTimeInterval(3600))
        let onListB = position(identifier: 3, itemIdentifier: 2, validFrom: now.addingTimeInterval(-1800), validUntil: now.addingTimeInterval(1800))
        let list = checkInList(allProducts: false, limitProducts: [2])
        let result = ReusableMediumPositionSelector.select(from: [offListFirst, onListA, onListB], checkInList: list, nowDate: now)
        XCTAssertEqual(result, .ambiguous(offListFirst))
    }
}
