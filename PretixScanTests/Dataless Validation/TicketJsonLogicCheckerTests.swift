//
//  TicketJsonLogicCheckerTests.swift
//  PretixScanTests
//
//  Created by Konstantin Kostov on 11/04/2022.
//  Copyright © 2022 rami.io. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import pretixSCAN

class TicketJsonLogicCheckerTests: XCTestCase {
    private let jsonDecoder = JSONDecoder.iso8601withFractionsDecoder
    
    private func getListWith(rules: JSON? = nil, list: String = "list2") -> CheckInList {
        let jsonData = testFileContents(list, "json")
        var exampleList = try! jsonDecoder.decode(CheckInList.self, from: jsonData)
        if let rules = rules {
            exampleList.rules = rules
        }
        return exampleList
    }
    
    func testListRulesCanBeSet() {
        let list = getListWith(rules: JSON(["foo": "bar"]))
        XCTAssertEqual(list.rules?.rawString(), "{\n  \"foo\" : \"bar\"\n}")
    }
    
    func testListRulesAreDecodedFromJSON() {
        let list = getListWith(rules: nil, list: "list2-rules")
        XCTAssertEqual(list.rules?.rawString(), "{\n  \"and\" : [\n    false,\n    true\n  ]\n}")
    }
    
    
    func testCheckerFailsSimpleRules() {
        let list = getListWith(rules: JSON(["and": [false, true]]))
        let sut = TicketJsonLogicChecker(list: list)
        
        let result = sut.redeem(ticket: mockTicket())
        
        switch result {
        case .success():
            XCTFail("Rules should be failing")
        case .failure(let err):
            XCTAssertEqual(err, .rules)
        }
    }
    
    func testCheckerValidatesSimpleRules() {
        let list = getListWith(rules: JSON(["and": [true, true]]))
        let sut = TicketJsonLogicChecker(list: list)
        
        let result = sut.redeem(ticket: mockTicket())
        switch result {
        case .success():
            break
        case .failure(let err):
            XCTFail("Expected success but failed with \(String(describing: err))")
        }
    }
    
    func testCheckerFailsRulesOnProduct() {
        let rules = """
{
  "inList": [
    { "var": "product" },
    { "objectList": [{ "lookup": ["product", "2", "Ticket"] }] }
  ]
}
"""
        let list = getListWith(rules: JSON(rules))
        let sut = TicketJsonLogicChecker(list: list)
        
        let result = sut.redeem(ticket: mockTicket())
        switch result {
        case .success():
            XCTFail("list2 has a product limit to producs with id 1 so the validation should fail since it requires product with id 2")
        case .failure(let err):
            XCTAssertEqual(err, .rules)
        }
    }
    
    func testCheckerValidatesRulesOnProduct() {
        let rules = """
{
  "inList": [
    { "var": "product" },
    { "objectList": [{ "lookup": ["product", "2", "Ticket"] }, { "lookup": ["product", "1", "Ticket"] }] }
  ]
}
"""
        let list = getListWith(rules: JSON(rules))
        let sut = TicketJsonLogicChecker(list: list)
        
        let result = sut.redeem(ticket: mockTicket())
        switch result {
        case .success():
            break
        case .failure(let err):
            XCTFail("Expected success but failed with \(String(describing: err))")
        }
    }
    
    func testCheckerFailsRulesOnVariation() {
        let rules = """
{
  "inList": [
    { "var": "variation" },
    { "objectList": [{ "lookup": ["variation", "3", "Ticket"] }] }
  ]
}
"""
        let list = getListWith(rules: JSON(rules))
        let sut = TicketJsonLogicChecker(list: list)
        
        let result = sut.redeem(ticket: mockTicket())
        switch result {
        case .success():
            XCTFail("variation limited to id 3 which is not present in mockticket with variation 2")
        case .failure(let err):
            XCTAssertEqual(err, .rules)
        }
    }
    
    func testCheckerValidatesRulesOnVariation() {
        let rules = """
{
  "inList": [
    { "var": "variation" },
    { "objectList": [{ "lookup": ["variation", "3", "Ticket"] }, { "lookup": ["variation", "2", "Ticket"] }] }
  ]
}
"""
        let list = getListWith(rules: JSON(rules))
        let sut = TicketJsonLogicChecker(list: list)
        
        let result = sut.redeem(ticket: mockTicket())
        switch result {
        case .success():
            break
        case .failure(let err):
            XCTFail("Expected success but failed with \(String(describing: err))")
        }
    }
    
    
    
    // MARK: - mocks
    
    func mockTicket(_ item: Identifier = 1, variation: Identifier = 2, subEvent: Identifier = 4) -> TicketJsonLogicChecker.TicketData {
        TicketJsonLogicChecker.TicketData(item: item, variation: variation, subEvent: subEvent)
    }
}
