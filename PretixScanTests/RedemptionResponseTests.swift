//
//  RedemptionResponseTests.swift
//  PretixScanTests
//
//  Created by Daniel Jilg on 25.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import XCTest
import SwiftUI
@testable import pretixSCAN

class RedemptionResponseTests: XCTestCase {
    private let jsonDecoder = JSONDecoder.iso8601withFractionsDecoder

    let exampleJSONOK = """
        {
            "status": "ok"
        }
    """.data(using: .utf8)!

    let exampleJSONError = """
        {
          "status": "error",
          "reason": "unpaid",
        }
    """.data(using: .utf8)!

    // Test parsing with when question handling is included
    let exampleJSONWithIncompleteQuestions = """
        {
            "status": "incomplete",
            "questions": [
                {
                  "id": 1,
                  "question": {"en": "T-Shirt size"},
                  "type": "C",
                  "required": false,
                  "items": [1, 2],
                  "position": 1,
                  "identifier": "WY3TP9SL",
                  "ask_during_checkin": true,
                  "options": [
                    {
                      "id": 1,
                      "identifier": "LVETRWVU",
                      "position": 0,
                      "answer": {"en": "S"}
                    },
                    {
                      "id": 2,
                      "identifier": "DFEMJWMJ",
                      "position": 1,
                      "answer": {"en": "M"}
                    },
                    {
                      "id": 3,
                      "identifier": "W9AH7RDE",
                      "position": 2,
                      "answer": {"en": "L"}
                    }
                  ]
                }
              ]
        }
    """.data(using: .utf8)!

    func testParsingOK() {
        XCTAssertNoThrow(try jsonDecoder.decode(RedemptionResponse.self, from: exampleJSONOK))
        let parsedInstance = try? jsonDecoder.decode(RedemptionResponse.self, from: exampleJSONOK)
        XCTAssertEqual(parsedInstance!.status, .redeemed)
    }

    func testParsingError() {
        XCTAssertNoThrow(try jsonDecoder.decode(RedemptionResponse.self, from: exampleJSONError))
        let parsedInstance = try? jsonDecoder.decode(RedemptionResponse.self, from: exampleJSONError)
        XCTAssertEqual(parsedInstance!.status, .error)
        XCTAssertEqual(parsedInstance!.errorReason, .unpaid)
    }

    let exampleJSONUnknownStatus = """
        {
            "status": "exchange",
            "reason_explanation": "Ticket needs to be exchanged to a suitable medium."
        }
    """.data(using: .utf8)!

    let exampleJSONUnknownReason = """
        {
            "status": "error",
            "reason": "some_brand_new_reason",
            "reason_explanation": "Server provided a reason this app does not know yet."
        }
    """.data(using: .utf8)!

    func testParsingUnknownStatus() {
        XCTAssertNoThrow(try jsonDecoder.decode(RedemptionResponse.self, from: exampleJSONUnknownStatus))
        let parsedInstance = try? jsonDecoder.decode(RedemptionResponse.self, from: exampleJSONUnknownStatus)
        XCTAssertEqual(parsedInstance!.status, .unknown)
        XCTAssertNil(parsedInstance!.errorReason)
        XCTAssertEqual(parsedInstance!.reasonExplanation, "Ticket needs to be exchanged to a suitable medium.")
    }

    func testParsingUnknownReason() {
        XCTAssertNoThrow(try jsonDecoder.decode(RedemptionResponse.self, from: exampleJSONUnknownReason))
        let parsedInstance = try? jsonDecoder.decode(RedemptionResponse.self, from: exampleJSONUnknownReason)
        XCTAssertEqual(parsedInstance!.status, .error)
        XCTAssertEqual(parsedInstance!.errorReason, .unknown)
        XCTAssertEqual(parsedInstance!.reasonExplanation, "Server provided a reason this app does not know yet.")
    }

    func testUnknownStatusAnnouncesExplanationAsError() {
        let parsedInstance = try? jsonDecoder.decode(RedemptionResponse.self, from: exampleJSONUnknownStatus)
        guard let parsedInstance = parsedInstance else {
            XCTFail("RedemptionResponse instance should be arranged")
            return
        }
        let announcement = TicketStatusAnnouncement(parsedInstance, nil, false, false, isOffline: false)
        XCTAssertEqual(announcement.reason, "Ticket needs to be exchanged to a suitable medium.")
        XCTAssertEqual(announcement.icon, Icon.error)
        XCTAssertEqual(announcement.background, Color(uiColor: PXColor.error))
    }
    
    func testResponseRulesParsing() {
        let jsonResponse = testFileContents("errorRules", "json")
        let redemptionResponse = try? jsonDecoder.decode(RedemptionResponse.self, from: jsonResponse)
        guard let redemptionResponse = redemptionResponse else {
            XCTFail("RedemptionResponse instance should be arranged")
            return
        }
        
        XCTAssertEqual(redemptionResponse.errorReason, .rules)
        XCTAssertEqual(redemptionResponse.reasonExplanation, "Minimum number of entries exceeded")
    }
    
    func testResponseErrorWithtRulesReason() {
        let jsonResponse = testFileContents("errorRules", "json")
        let redemptionResponse = try? jsonDecoder.decode(RedemptionResponse.self, from: jsonResponse)
        guard let redemptionResponse = redemptionResponse else {
            XCTFail("RedemptionResponse instance should be arranged")
            return
        }
        
        XCTAssertEqual(redemptionResponse.localizedErrorReason, "\(RedemptionResponse.ErrorReason.rules.localizedDescription()): Minimum number of entries exceeded")
    }
    
    func testSetsRequiresAttention() {
        let jsonResponse = testFileContents("redeemed")
        let redemptionResponse = try? jsonDecoder.decode(RedemptionResponse.self, from: jsonResponse)
        guard let redemptionResponse = redemptionResponse else {
            XCTFail("RedemptionResponse instance should be arranged")
            return
        }
        XCTAssertTrue(redemptionResponse.isRequireAttention)
    }
    
    func testHandleInlineQuestionObjects() {
        let jsonResponse = testFileContents("redeem1")
        let redemptionResponse = try? jsonDecoder.decode(RedemptionResponse.self, from: jsonResponse)
        guard let redemptionResponse = redemptionResponse else {
            XCTFail("RedemptionResponse instance should be arranged")
            return
        }
        XCTAssertNotNil(redemptionResponse.position?.answers)
        XCTAssertEqual(redemptionResponse.position!.answers![0].question.displayQuestion, "Question on screen")
    }
    
    func testAppendsQuestionsAsCheckInTexts() {
        let jsonResponse = testFileContents("redeem1")
        let redemptionResponse = try? jsonDecoder.decode(RedemptionResponse.self, from: jsonResponse)
        guard let redemptionResponse = redemptionResponse else {
            XCTFail("RedemptionResponse instance should be arranged")
            return
        }
        let result = RedemptionResponse.appendDataFromOnlineQuestionsForStatusVisualization(redemptionResponse)
        
        // check-in texts are ordered: Questions > Order > Variation > Item
        XCTAssertEqual(result.checkInTexts, ["check-in on product"])
        XCTAssertEqual(result.visibleAnswers, [.init(key: "Question on screen", value: "Some answer")])
    }
}
