//
//  RedemptionResponseTests.swift
//  PretixScanTests
//
//  Created by Daniel Jilg on 25.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import XCTest

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
}
