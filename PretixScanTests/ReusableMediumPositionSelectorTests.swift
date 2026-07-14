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
    private func position(identifier: Identifier, validFrom: Date? = nil, validUntil: Date? = nil) -> OrderPosition {
        OrderPosition(
            identifier: identifier, orderCode: "W0JKM", orderStatus: .paid, order: nil, positionid: identifier, itemIdentifier: 1,
            item: nil, variation: nil, price: "10.00", attendeeName: nil, attendeeEmail: nil,
            secret: "secret\(identifier)", subEvent: nil, pseudonymizationId: "PSEUDO\(identifier)",
            checkins: [], answers: [], seat: nil, requiresAttention: nil, blocked: nil, validFrom: validFrom, validUntil: validUntil)
    }

    func testEmptyPositionsReturnsNil() {
        XCTAssertNil(ReusableMediumPositionSelector.select(from: []))
    }

    func testSingleCandidateIsUsedDirectly() {
        let position = position(identifier: 1)
        let result = ReusableMediumPositionSelector.select(from: [position])
        XCTAssertEqual(result, .position(position))
    }

    func testTwoCandidatesWithoutTimeWindowsAreAmbiguous() {
        let positionA = position(identifier: 1)
        let positionB = position(identifier: 2)
        let result = ReusableMediumPositionSelector.select(from: [positionA, positionB])
        XCTAssertEqual(result, .ambiguous)
    }

    func testTwoCandidatesWithOverlappingWindowsAreAmbiguous() {
        let now = Date()
        let positionA = position(identifier: 1, validFrom: now.addingTimeInterval(-3600), validUntil: now.addingTimeInterval(3600))
        let positionB = position(identifier: 2, validFrom: now.addingTimeInterval(-1800), validUntil: now.addingTimeInterval(1800))
        let result = ReusableMediumPositionSelector.select(from: [positionA, positionB], nowDate: now)
        XCTAssertEqual(result, .ambiguous)
    }

    func testDisjointWindowsPicksTheCurrentlyValidOne() {
        let now = Date()
        let past = position(identifier: 1, validFrom: now.addingTimeInterval(-7200), validUntil: now.addingTimeInterval(-3600))
        let current = position(identifier: 2, validFrom: now.addingTimeInterval(-1800), validUntil: now.addingTimeInterval(1800))
        let future = position(identifier: 3, validFrom: now.addingTimeInterval(3600), validUntil: now.addingTimeInterval(7200))
        let result = ReusableMediumPositionSelector.select(from: [past, current, future], nowDate: now)
        XCTAssertEqual(result, .position(current))
    }

    func testGapBetweenWindowsPicksNearestFutureAsInvalidTime() {
        let now = Date()
        let earlier = position(identifier: 1, validFrom: now.addingTimeInterval(-7200), validUntil: now.addingTimeInterval(-3600))
        let nearFuture = position(identifier: 2, validFrom: now.addingTimeInterval(1800), validUntil: now.addingTimeInterval(3600))
        let farFuture = position(identifier: 3, validFrom: now.addingTimeInterval(7200), validUntil: now.addingTimeInterval(10800))
        let result = ReusableMediumPositionSelector.select(from: [earlier, nearFuture, farFuture], nowDate: now)
        XCTAssertEqual(result, .invalidTime(nearFuture))
    }

    func testAfterAllWindowsPicksTheLastPastCandidateAsInvalidTime() {
        let now = Date()
        let earlier = position(identifier: 1, validFrom: now.addingTimeInterval(-14400), validUntil: now.addingTimeInterval(-10800))
        let later = position(identifier: 2, validFrom: now.addingTimeInterval(-7200), validUntil: now.addingTimeInterval(-3600))
        let result = ReusableMediumPositionSelector.select(from: [earlier, later], nowDate: now)
        XCTAssertEqual(result, .invalidTime(later))
    }
}
