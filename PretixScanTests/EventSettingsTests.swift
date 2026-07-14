//
//  EventSettingsTests.swift
//  PretixScanTests
//
//  Created by Konstantin Kostov on 15/07/2026.
//  Copyright © 2026 rami.io. All rights reserved.
//

import XCTest
@testable import pretixSCAN

class EventSettingsTests: XCTestCase {
    func testDecodesReusableMediaUsageEnforcedTrue() throws {
        let json = #"{"reusable_media_usage_enforced": true}"#.data(using: .utf8)!
        let settings = try JSONDecoder.iso8601withFractionsDecoder.decode(EventSettings.self, from: json)
        XCTAssertTrue(settings.reusableMediaUsageEnforced)
    }

    func testDecodesReusableMediaUsageEnforcedFalse() throws {
        let json = #"{"reusable_media_usage_enforced": false}"#.data(using: .utf8)!
        let settings = try JSONDecoder.iso8601withFractionsDecoder.decode(EventSettings.self, from: json)
        XCTAssertFalse(settings.reusableMediaUsageEnforced)
    }

    func testDefaultsToFalseWhenKeyIsAbsent() throws {
        let json = "{}".data(using: .utf8)!
        let settings = try JSONDecoder.iso8601withFractionsDecoder.decode(EventSettings.self, from: json)
        XCTAssertFalse(settings.reusableMediaUsageEnforced)
    }
}
