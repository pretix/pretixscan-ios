//
//  ReusableMediumTests.swift
//  PretixScanTests
//
//  Created by Konstantin Kostov on 14/07/2026.
//  Copyright © 2026 rami.io. All rights reserved.
//

import XCTest
@testable import pretixSCAN

class ReusableMediumTests: XCTestCase {
    private let jsonDecoder = JSONDecoder.iso8601withFractionsDecoder

    func testDecodingWithLinkedOrderPositionsArrayAndNullExpires() throws {
        let data = testFileContents("reusablemedium1")
        let medium = try jsonDecoder.decode(ReusableMedium.self, from: data)

        XCTAssertEqual(medium.identifier, 27)
        XCTAssertEqual(medium.type, "barcode")
        XCTAssertEqual(medium.mediumIdentifier, "1111")
        XCTAssertTrue(medium.active)
        XCTAssertNil(medium.expires)
        XCTAssertNil(medium.customer)
        XCTAssertEqual(medium.linkedOrderPositions, [18697, 18698])
        XCTAssertNil(medium.linkedGiftCard)
        XCTAssertEqual(medium.created, Formatter.iso8601.date(from: "2026-05-08T10:00:05.758077Z"))
    }

    func testDecodingFallsBackToLegacyScalarLinkedOrderPosition() throws {
        let data = testFileContents("reusablemedium-legacy")
        let medium = try jsonDecoder.decode(ReusableMedium.self, from: data)

        XCTAssertEqual(medium.identifier, 42)
        XCTAssertEqual(medium.mediumIdentifier, "5555")
        XCTAssertEqual(medium.customer, "customer@example.org")
        XCTAssertNotNil(medium.expires)
        XCTAssertEqual(medium.linkedOrderPositions, [18699])
    }

    func testHashableUsesIdentifier() throws {
        let data = testFileContents("reusablemedium1")
        let medium1 = try jsonDecoder.decode(ReusableMedium.self, from: data)
        let medium2 = try jsonDecoder.decode(ReusableMedium.self, from: data)

        XCTAssertEqual(medium1, medium2)
        XCTAssertEqual(medium1.hashValue, medium2.hashValue)
    }
}
