//
//  ReusableMediaDownloaderTests.swift
//  PretixScanTests
//
//  Created by Konstantin Kostov on 14/07/2026.
//  Copyright © 2026 rami.io. All rights reserved.
//

import XCTest
@testable import pretixSCAN

class ReusableMediaDownloaderTests: XCTestCase {
    func testNeverSyncedStartsFullFetchFromTheBeginning() {
        let strategy = ReusableMediaFetchStrategy.decide(lastSyncCreationTime: nil, lastSyncTime: nil)
        XCTAssertEqual(strategy, .full(createdSince: nil, resumedGeneratedAt: nil))
    }

    func testInterruptedFullFetchResumesFromLastCreatedWatermark() {
        let strategy = ReusableMediaFetchStrategy.decide(lastSyncCreationTime: "2026-01-01T00:00:00+01:00", lastSyncTime: nil)
        XCTAssertEqual(strategy, .full(createdSince: "2026-01-01T00:00:00+01:00", resumedGeneratedAt: nil))
    }

    func testCompletedFullFetchWithoutModifiedWatermarkRestartsFullFetch() {
        let strategy = ReusableMediaFetchStrategy.decide(lastSyncCreationTime: "complete", lastSyncTime: nil)
        XCTAssertEqual(strategy, .full(createdSince: nil, resumedGeneratedAt: nil))
    }

    func testCompletedFullFetchWithModifiedWatermarkGoesIncremental() {
        let strategy = ReusableMediaFetchStrategy.decide(lastSyncCreationTime: "complete", lastSyncTime: "2026-01-02T00:00:00+01:00")
        XCTAssertEqual(strategy, .incremental(updatedSince: "2026-01-02T00:00:00+01:00"))
    }

    func testInterruptedFullFetchResumesWithOriginGeneratedAtWatermark() {
        let strategy = ReusableMediaFetchStrategy.decide(
            lastSyncCreationTime: "2026-01-01T00:00:00+01:00|Mon, 01 Jan 2026 00:00:00 GMT", lastSyncTime: nil)
        XCTAssertEqual(strategy, .full(createdSince: "2026-01-01T00:00:00+01:00", resumedGeneratedAt: "Mon, 01 Jan 2026 00:00:00 GMT"))
    }
}
