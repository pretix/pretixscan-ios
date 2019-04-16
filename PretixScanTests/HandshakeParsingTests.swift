//
//  ModelParsingTests.swift
//  PretixScanTests
//
//  Created by Daniel Jilg on 14.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import XCTest

class HandshakeParsingTests: XCTestCase {
    let validHandshake = Handshake(url: URL(string: "https://pretix.eu")!, token: "kpp4jn8g2ynzonp6")

    let validJSON = """
            {"handshake_version": 1, "url": "https://pretix.eu", "token": "kpp4jn8g2ynzonp6"}
            """.data(using: .utf8)!

    let invalidJSON = """
            {"handshake_version": 1, "url": "this is not a url", "token": "kpp4jn8g2ynzonp6"}
            """.data(using: .utf8)!

    func testEncodingValidHandshake() {
        let parsedHandshake = try? JSONDecoder.iso8601withFractionsDecoder.decode(Handshake.self, from: validJSON)
        XCTAssertNotNil(parsedHandshake)
        XCTAssertEqual(parsedHandshake, validHandshake)
    }

    func testEncodingInvalidHandshake() {
        let invalidHandshake = try? JSONDecoder.iso8601withFractionsDecoder.decode(Handshake.self, from: invalidJSON)
        XCTAssertNil(invalidHandshake)
    }
}
