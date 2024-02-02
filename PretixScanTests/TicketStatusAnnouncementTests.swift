//
//  TicketStatusAnnouncementTests.swift
//  PretixScanTests
//
//  Created by Konstantin Kostov on 02/02/2024.
//  Copyright © 2024 rami.io. All rights reserved.
//

import XCTest
@testable import pretixSCAN

final class TicketStatusAnnouncementTests: XCTestCase {

    func testUnknownAppError() {
        let result = TicketStatusAnnouncement.init(nil, APIError.badRequest, false, false, isOffline: false)
        XCTAssertFalse(result.showOfflineIndicator)
        XCTAssertEqual(result.reason, "The server refused to handle our request")
    }
    
    func testUnknownError() {
        let result = TicketStatusAnnouncement.init(nil, NSError(domain: "foo", code: 1), false, false, isOffline: false)
        XCTAssertFalse(result.showOfflineIndicator)
        XCTAssertEqual(result.reason, "The operation couldn’t be completed. (foo error 1.)")
    }
}
