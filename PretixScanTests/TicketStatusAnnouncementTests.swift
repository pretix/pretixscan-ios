//
//  TicketStatusAnnouncementTests.swift
//  PretixScanTests
//
//  Created by Konstantin Kostov on 02/02/2024.
//  Copyright © 2024 rami.io. All rights reserved.
//

import XCTest
import SwiftUI
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

    func testExchangeStatus() {
        let response = RedemptionResponse(status: .exchange, reasonExplanation: nil, errorReason: nil, questions: nil)
        let result = TicketStatusAnnouncement.init(response, nil, false, false, isOffline: false)
        XCTAssertEqual(result.status, Localization.TicketStatus.MediumExchangeNeeded)
        XCTAssertEqual(result.reason, Localization.TicketStatus.MediumExchangeNeededReason)
        XCTAssertEqual(result.icon, Icon.error)
        XCTAssertEqual(result.background, Color(uiColor: PXColor.error))
    }

    func testAlreadyExchangedReason() {
        let response = RedemptionResponse(status: .error, reasonExplanation: nil, errorReason: .alreadyExchanged, questions: nil)
        let result = TicketStatusAnnouncement.init(response, nil, false, false, isOffline: false)
        XCTAssertEqual(result.status, Localization.TicketStatus.TicketAlreadyExchanged)
        XCTAssertEqual(result.icon, Icon.error)
        XCTAssertEqual(result.background, Color(uiColor: PXColor.error))
    }

    func testExchangeOfflineReason() {
        let response = RedemptionResponse(status: .error, reasonExplanation: nil, errorReason: .exchangeOffline, questions: nil)
        let result = TicketStatusAnnouncement.init(response, nil, false, false, isOffline: false)
        XCTAssertEqual(result.status, Localization.TicketStatus.MediumExchangeNeeded)
    }

    func testMediumInvalidReason() {
        let response = RedemptionResponse(status: .error, reasonExplanation: nil, errorReason: .mediumInvalid, questions: nil)
        let result = TicketStatusAnnouncement.init(response, nil, false, false, isOffline: false)
        XCTAssertEqual(result.status, Localization.TicketStatus.InvalidTicket)
        XCTAssertEqual(result.reason, RedemptionResponse.ErrorReason.mediumInvalid.localizedDescription())
    }

    func testMediumExistsReason() {
        let response = RedemptionResponse(status: .error, reasonExplanation: nil, errorReason: .mediumExists, questions: nil)
        let result = TicketStatusAnnouncement.init(response, nil, false, false, isOffline: false)
        XCTAssertEqual(result.status, Localization.TicketStatus.InvalidTicket)
        XCTAssertEqual(result.reason, RedemptionResponse.ErrorReason.mediumExists.localizedDescription())
    }
}
