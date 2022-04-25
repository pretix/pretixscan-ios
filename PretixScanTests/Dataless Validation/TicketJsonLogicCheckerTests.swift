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
    
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = TicketJsonLogicChecker.DateFormat
        return formatter
    }()
    
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
        let sut = TicketJsonLogicChecker(list: list, event: mockEvent())
        
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
        let sut = TicketJsonLogicChecker(list: list, event: mockEvent())
        
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
        let sut = TicketJsonLogicChecker(list: list, event: mockEvent())
        
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
        let sut = TicketJsonLogicChecker(list: list, event: mockEvent())
        
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
        let sut = TicketJsonLogicChecker(list: list, event: mockEvent())
        
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
        let sut = TicketJsonLogicChecker(list: list, event: mockEvent())
        
        let result = sut.redeem(ticket: mockTicket())
        switch result {
        case .success():
            break
        case .failure(let err):
            XCTFail("Expected success but failed with \(String(describing: err))")
        }
    }
    
    
    func testCheckerFailsRulesOnEntriesToday() {
        // arrange
        let rules = """
{ "<": [{ "var": "entries_today" }, 1] }
"""
        let list = getListWith(rules: JSON(rules))
        let ds = mockDataStore([
            // entry in the past
            .init(redemptionRequest: .init(date: Date.distantPast, ignoreUnpaid: false, nonce: "", type: "entry"), eventSlug: "", checkInListIdentifier: 0, secret: ""),
            // exit today
            .init(redemptionRequest: .init(date: Date(), ignoreUnpaid: false, nonce: "", type: "exit"), eventSlug: "", checkInListIdentifier: 0, secret: ""),
            // entry today
            .init(redemptionRequest: .init(date: Date(), ignoreUnpaid: false, nonce: "", type: "entry"), eventSlug: "", checkInListIdentifier: 0, secret: "")
        ])
        let sut = TicketJsonLogicChecker(list: list, dataStore: ds, event: mockEvent())
        
        // act
        let result = sut.redeem(ticket: mockTicket())
        switch result {
        case .success():
            XCTFail("number of entries for today < 1, this is the second checkin and should fail")
        case .failure(let err):
            XCTAssertEqual(err, .rules)
        }
    }
    
    func testCheckerValidatesRulesOnEntriesToday() {
        // arrange
        let rules = """
{ "<": [{ "var": "entries_today" }, 1] }
"""
        let list = getListWith(rules: JSON(rules))
        let ds = mockDataStore([
            // entry in the past
            .init(redemptionRequest: .init(date: Date.distantPast, ignoreUnpaid: false, nonce: "", type: "entry"), eventSlug: "", checkInListIdentifier: 0, secret: ""),
            // exit today
            .init(redemptionRequest: .init(date: Date(), ignoreUnpaid: false, nonce: "", type: "exit"), eventSlug: "", checkInListIdentifier: 0, secret: ""),
        ])
        let sut = TicketJsonLogicChecker(list: list, dataStore: ds, event: mockEvent())
        
        // act
        let result = sut.redeem(ticket: mockTicket())
        switch result {
        case .success():
            break
        case .failure(let err):
            XCTFail("Expected success but failed with \(String(describing: err))")
        }
    }
    
    
    func testCheckerFailsRulesOnEntriesNumber() {
        // arrange
        let rules = """
{ "<": [{ "var": "entries_number" }, 1] }
"""
        let list = getListWith(rules: JSON(rules))
        let ds = mockDataStore([
            // entry in the past
            .init(redemptionRequest: .init(date: Date.distantPast, ignoreUnpaid: false, nonce: "", type: "entry"), eventSlug: "", checkInListIdentifier: 0, secret: ""),
            // exit today
            .init(redemptionRequest: .init(date: Date(), ignoreUnpaid: false, nonce: "", type: "exit"), eventSlug: "", checkInListIdentifier: 0, secret: ""),
        ])
        let sut = TicketJsonLogicChecker(list: list, dataStore: ds, event: mockEvent())
        
        // act
        let result = sut.redeem(ticket: mockTicket())
        switch result {
        case .success():
            XCTFail("number of entries < 1, this is the second checkin and should fail")
        case .failure(let err):
            XCTAssertEqual(err, .rules)
        }
    }
    
    func testCheckerValidatesRulesOnEntriesNumber() {
        // arrange
        let rules = """
{ "<": [{ "var": "entries_number" }, 1] }
"""
        let list = getListWith(rules: JSON(rules))
        let ds = mockDataStore([])
        let sut = TicketJsonLogicChecker(list: list, dataStore: ds, event: mockEvent())
        
        // act
        let result = sut.redeem(ticket: mockTicket())
        switch result {
        case .success():
            break
        case .failure(let err):
            XCTFail("Expected success but failed with \(String(describing: err))")
        }
    }
    
    func testGetEntriesDaysCount() {
        let dates = [
            dateFormatter.date(from: "2022-03-19T07:18:00.000Z")!,
            dateFormatter.date(from: "2022-03-20T07:08:00.000Z")!,
            dateFormatter.date(from: "2022-04-19T07:13:00.000Z")!,
            dateFormatter.date(from: "2021-04-19T07:30:00.000Z")!,
        ]
        
        let checkIns: [QueuedRedemptionRequest] = dates.map({
            .init(redemptionRequest: .init(date: $0, ignoreUnpaid: false, nonce: "", type: "entry"), eventSlug: "", checkInListIdentifier: 0, secret: "")
        })
        
        let count = TicketJsonLogicChecker.getEntriesDaysCount(checkIns, calendar: Calendar.current)
        
        XCTAssertEqual(count, 4)
    }
    
    func testGetEntriesTodayCount() {
        let dates = [
            dateFormatter.date(from: "2022-03-19T07:28:00.000Z")!,
            dateFormatter.date(from: "2022-03-20T07:28:00.000Z")!,
            dateFormatter.date(from: "2022-04-19T07:28:00.000Z")!,
            dateFormatter.date(from: "2021-04-19T07:30:00.000Z")!,
        ]
        
        let checkIns: [QueuedRedemptionRequest] = dates.map({
            .init(redemptionRequest: .init(date: $0, ignoreUnpaid: false, nonce: "", type: "entry"), eventSlug: "", checkInListIdentifier: 0, secret: "")
        })
        
        let count = TicketJsonLogicChecker.getEntriesTodayCount(checkIns, calendar: Calendar.current, today: dateFormatter.date(from: "2022-04-19T16:00:00.000Z")!)
        
        XCTAssertEqual(count, 1)
    }
    
    func testCheckerFailsRulesOnEntriesDays() {
        // Ticket is valid unlimited times, but only on two arbitrary days
        let rules = """
{
  "or": [
    { ">": [{ "var": "entries_today" }, 0] },
    { "<": [{ "var": "entries_days" }, 2] }
  ]
}
"""
        let dates = [dateFormatter.date(from: "2022-03-19T07:28:00.000Z")!, dateFormatter.date(from: "2022-04-19T07:28:00.000Z")!]
        let now = dateFormatter.date(from: "2022-05-19T07:28:00.000Z")!
        
        let list = getListWith(rules: JSON(rules))
        let ds = mockDataStore([
            .init(redemptionRequest: .init(date: dates[0], ignoreUnpaid: false, nonce: "", type: "entry"), eventSlug: "", checkInListIdentifier: 0, secret: ""),
            .init(redemptionRequest: .init(date: dates[0], ignoreUnpaid: false, nonce: "", type: "exit"), eventSlug: "", checkInListIdentifier: 0, secret: ""),
            .init(redemptionRequest: .init(date: dates[1], ignoreUnpaid: false, nonce: "", type: "entry"), eventSlug: "", checkInListIdentifier: 0, secret: ""),
            .init(redemptionRequest: .init(date: dates[1], ignoreUnpaid: false, nonce: "", type: "exit"), eventSlug: "", checkInListIdentifier: 0, secret: ""),
        ])
        let sut = TicketJsonLogicChecker(list: list, dataStore: ds, event: mockEvent(), date: now)
        
        // act
        let result = sut.redeem(ticket: mockTicket())
        switch result {
        case .success():
            XCTFail("attempted redeem on a 3rd day should fail")
        case .failure(let err):
            XCTAssertEqual(err, .rules)
        }
        
    }
    
    func testCheckerValidatesRulesOnEntriesDays() {
        // Ticket is valid unlimited times, but only on two arbitrary days
        let rules = """
{
  "or": [
    { ">": [{ "var": "entries_today" }, 0] },
    { "<": [{ "var": "entries_days" }, 2] }
  ]
}
"""
        let dates = [dateFormatter.date(from: "2022-03-19T07:28:00.000Z")!]
        let now = dateFormatter.date(from: "2022-05-19T07:28:00.000Z")!
        
        let list = getListWith(rules: JSON(rules))
        let ds = mockDataStore([
            .init(redemptionRequest: .init(date: dates[0], ignoreUnpaid: false, nonce: "", type: "entry"), eventSlug: "", checkInListIdentifier: 0, secret: ""),
            .init(redemptionRequest: .init(date: dates[0], ignoreUnpaid: false, nonce: "", type: "exit"), eventSlug: "", checkInListIdentifier: 0, secret: ""),
        ])
        let sut = TicketJsonLogicChecker(list: list, dataStore: ds, event: mockEvent(), date: now)
        
        // act
        let result = sut.redeem(ticket: mockTicket())
        switch result {
        case .success():
            break
        case .failure(let err):
            XCTFail("Expected success but failed with \(String(describing: err))")
        }
        
    }
    
    func testCheckerFailsCheckinBeforeAdmissionDateTollerance() {
        let rules = """
{ "isAfter": [{ "var": "now" }, { "buildTime": ["date_admission"] }, 10] }
"""
        let now = dateFormatter.date(from: "2020-01-01T08:45:00.000Z")!
        
        let list = getListWith(rules: JSON(rules))
        let ds = mockDataStore([])
        // mock event dateAdmission = 2020-01-01T09:00:00Z
        let sut = TicketJsonLogicChecker(list: list, dataStore: ds, event: mockEvent(), date: now)
        
        switch sut.redeem(ticket: mockTicket()) {
        case .success():
            XCTFail("attempted redeem sooner than admission date")
        case .failure(let err):
            XCTAssertEqual(err, .rules)
        }
    }
    
    func testCheckerFailsCheckinBeforeAdmissionDateNoTollerance() {
        let rules = """
{ "isAfter": [{ "var": "now" }, { "buildTime": ["date_admission"] }, null] }
"""
        let now = dateFormatter.date(from: "2020-01-01T08:45:00.000Z")!
        
        let list = getListWith(rules: JSON(rules))
        let ds = mockDataStore([])
        // mock event dateAdmission = 2020-01-01T09:00:00Z
        let sut = TicketJsonLogicChecker(list: list, dataStore: ds, event: mockEvent(), date: now)
        
        switch sut.redeem(ticket: mockTicket()) {
        case .success():
            XCTFail("attempted redeem sooner than admission date")
        case .failure(let err):
            XCTAssertEqual(err, .rules)
        }
    }
    
    func testCheckerValidatesCheckinBeforeAdmissionDateTollerance() {
        let rules = """
{ "isAfter": [{ "var": "now" }, { "buildTime": ["date_admission"] }, 10] }
"""
        let now = dateFormatter.date(from: "2020-01-01T08:51:00.000Z")!
        
        let list = getListWith(rules: JSON(rules))
        let ds = mockDataStore([])
        // mock event dateAdmission = 2020-01-01T09:00:00Z
        let sut = TicketJsonLogicChecker(list: list, dataStore: ds, event: mockEvent(), date: now)
        
        switch sut.redeem(ticket: mockTicket()) {
        case .success():
            break
        case .failure(let err):
            XCTFail("Expected success but failed with \(String(describing: err))")
        }
    }
    
    func testCheckerValidatesCheckinBeforeAdmissionDateNoTollerance() {
        let rules = """
{ "isAfter": [{ "var": "now" }, { "buildTime": ["date_admission"] }, null] }
"""
        let now = dateFormatter.date(from: "2020-01-01T08:51:00.000Z")!
        
        let list = getListWith(rules: JSON(rules))
        let ds = mockDataStore([])
        // mock event dateAdmission = 2020-01-01T09:00:00Z
        let sut = TicketJsonLogicChecker(list: list, dataStore: ds, event: mockEvent(), date: now)
        
        switch sut.redeem(ticket: mockTicket()) {
        case .success():
            XCTFail("attempted redeem sooner than admission date")
        case .failure(let err):
            XCTAssertEqual(err, .rules)
        }
    }
    
    func testCheckerValidatesCheckinAfterAdmissionDateTollerance() {
        let rules = """
{ "isAfter": [{ "var": "now" }, { "buildTime": ["date_admission"] }, 10] }
"""
        let now = dateFormatter.date(from: "2020-01-01T09:10:00.000Z")!
        
        let list = getListWith(rules: JSON(rules))
        let ds = mockDataStore([])
        // mock event dateAdmission = 2020-01-01T09:00:00Z
        let sut = TicketJsonLogicChecker(list: list, dataStore: ds, event: mockEvent(), date: now)
        
        switch sut.redeem(ticket: mockTicket()) {
        case .success():
            break
        case .failure(let err):
            XCTFail("Expected success but failed with \(String(describing: err))")
        }
    }
    
    func testCheckerValidatesCheckinAfterAdmissionDateNoTollerance() {
        let rules = """
{ "isAfter": [{ "var": "now" }, { "buildTime": ["date_admission"] }, null] }
"""
        let now = dateFormatter.date(from: "2020-01-01T09:10:00.000Z")!
        
        let list = getListWith(rules: JSON(rules))
        let ds = mockDataStore([])
        // mock event dateAdmission = 2020-01-01T09:00:00Z
        let sut = TicketJsonLogicChecker(list: list, dataStore: ds, event: mockEvent(), date: now)
        
        switch sut.redeem(ticket: mockTicket()) {
        case .success():
            break
        case .failure(let err):
            XCTFail("Expected success but failed with \(String(describing: err))")
        }
    }
    
    func testCheckerFailsDateIsAfterToleranceFromSubEvent() {
        let rules = """
{ "isAfter": [{ "var": "now" }, { "buildTime": ["date_admission"] }, 10] }
"""
        let now = dateFormatter.date(from: "2020-01-01T09:10:00.000Z")!
        
        let list = getListWith(rules: JSON(rules))
        let ds = mockDataStore([])
        // mock event dateAdmission = 2020-01-01T09:00:00Z
        // mock subevent dateAdmission = 2020-02-01T09:00:00Z
        let sut = TicketJsonLogicChecker(list: list, dataStore: ds, event: mockEvent("event1-se"), subEvent: mockSubEvent(), date: now)
        
        switch sut.redeem(ticket: mockTicket()) {
        case .success():
            XCTFail("attempted redeem sooner than admission date of the subevent")
        case .failure(let err):
            XCTAssertEqual(err, .rules)
        }
    }
    
    func testCheckerValidatesDateIsAfterToleranceFromSubEvent() {
        let rules = """
{ "isAfter": [{ "var": "now" }, { "buildTime": ["date_admission"] }, 10] }
"""
        let now = dateFormatter.date(from: "2020-02-01T08:56:00.000Z")!
        
        let list = getListWith(rules: JSON(rules))
        let ds = mockDataStore([])
        // mock event dateAdmission = 2020-01-01T09:00:00Z
        // mock subevent dateAdmission = 2020-02-01T09:00:00Z
        let sut = TicketJsonLogicChecker(list: list, dataStore: ds, event: mockEvent("event1-se"), subEvent: mockSubEvent(), date: now)
        
        switch sut.redeem(ticket: mockTicket()) {
        case .success():
            break
        case .failure(let err):
            XCTFail("Expected success but failed with \(String(describing: err))")
        }
    }
    
    func testCheckerValidatesCheckinBeforeDateToTollerance() {
        let rules = """
{ "isBefore": [{ "var": "now" }, { "buildTime": ["date_to"] }, 10] }
"""
        let now = dateFormatter.date(from: "2020-01-01T14:05:00.000Z")!
        // mock event dateTo = 2020-01-01T14:00:00Z
        switch TicketJsonLogicChecker(list: getListWith(rules: JSON(rules)), dataStore: mockDataStore([]), event: mockEvent(), date: now).redeem(ticket: mockTicket()) {
        case .success():
            break
        case .failure(let err):
            XCTFail("Expected success but failed with \(String(describing: err))")
        }
        
    }
    
    func testCheckerFailsCheckinBeforeDateToTollerance() {
        let rules = """
{ "isBefore": [{ "var": "now" }, { "buildTime": ["date_to"] }, 10] }
"""
        let now = dateFormatter.date(from: "2020-01-01T14:15:00.000Z")!
        // mock event dateTo = 2020-01-01T14:00:00Z
        switch TicketJsonLogicChecker(list: getListWith(rules: JSON(rules)), dataStore: mockDataStore([]), event: mockEvent(), date: now).redeem(ticket: mockTicket()) {
        case .success():
            XCTFail("attempted redeem before date_to tollerance should fail")
        case .failure(let err):
            XCTAssertEqual(err, .rules)
        }
    }
    
    func testCheckerValidatesCheckinBeforeDateToNoTollerance() {
        let rules = """
{ "isBefore": [{ "var": "now" }, { "buildTime": ["date_to"] }, null] }
"""
        let now = dateFormatter.date(from: "2020-01-01T13:55:00.000Z")!
        // mock event dateTo = 2020-01-01T14:00:00Z
        switch TicketJsonLogicChecker(list: getListWith(rules: JSON(rules)), dataStore: mockDataStore([]), event: mockEvent(), date: now).redeem(ticket: mockTicket()) {
        case .success():
            break
        case .failure(let err):
            XCTFail("Expected success but failed with \(String(describing: err))")
        }
        
    }
    
    func testCheckerFailsCheckinBeforeDateToNoTollerance() {
        let rules = """
{ "isBefore": [{ "var": "now" }, { "buildTime": ["date_to"] }, null] }
"""
        let now = dateFormatter.date(from: "2020-01-01T14:15:00.000Z")!
        // mock event dateTo = 2020-01-01T14:00:00Z
        switch TicketJsonLogicChecker(list: getListWith(rules: JSON(rules)), dataStore: mockDataStore([]), event: mockEvent(), date: now).redeem(ticket: mockTicket()) {
        case .success():
            XCTFail("attempted redeem before date_to tollerance should fail")
        case .failure(let err):
            XCTAssertEqual(err, .rules)
        }
    }
    
    func testCheckerValidatesIsAfterCustomDateTime() {
        let rules = """
{ "isAfter": [{ "var": "now" }, { "buildTime": ["custom", "2020-01-01T22:00:00.000Z"] }] }
"""
        let now1 = dateFormatter.date(from: "2020-01-01T21:51:00.000Z")!
        switch TicketJsonLogicChecker(list: getListWith(rules: JSON(rules)), dataStore: mockDataStore([]), event: mockEvent(), date: now1).redeem(ticket: mockTicket()) {
        case .success():
            XCTFail("attempted redeem before custom datetime should fail")
        case .failure(let err):
            XCTAssertEqual(err, .rules)
        }
        
        let now2 = dateFormatter.date(from: "2020-01-01T22:01:00.000Z")!
        switch TicketJsonLogicChecker(list: getListWith(rules: JSON(rules)), dataStore: mockDataStore([]), event: mockEvent(), date: now2).redeem(ticket: mockTicket()) {
        case .success():
            break
        case .failure(let err):
            XCTFail("Expected success but failed with \(String(describing: err))")
        }
    }
    
    func testCheckerFailsIsAfterCustomTime() {
        let rules = """
{ "isAfter": [{ "var": "now" }, { "buildTime": ["customtime", "14:00"] }] }
"""
        let now = dateFormatter.date(from: "2020-01-01T04:50:00.000Z")!
        switch TicketJsonLogicChecker(list: getListWith(rules: JSON(rules)), dataStore: mockDataStore([]), event: mockEvent(), date: now).redeem(ticket: mockTicket()) {
        case .success():
            XCTFail("attempted redeem before customtime should fail")
        case .failure(let err):
            XCTAssertEqual(err, .rules)
        }
    }
    
    func testCheckerValidatesIsAfterCustomTime() {
        let rules = """
{ "isAfter": [{ "var": "now" }, { "buildTime": ["customtime", "14:00"] }] }
"""
        let now = dateFormatter.date(from: "2020-01-01T05:01:00.000Z")!
        switch TicketJsonLogicChecker(list: getListWith(rules: JSON(rules)), dataStore: mockDataStore([]), event: mockEvent(), date: now).redeem(ticket: mockTicket()) {
        case .success():
            break
        case .failure(let err):
            XCTFail("Expected success but failed with \(String(describing: err))")
        }
    }
    
    func testValidatesUsingISOWeekDay() {
        let rules = """
{ "==": [{ "var": "now_isoweekday" }, 1] }
"""
        let now = dateFormatter.date(from: "2022-04-25T05:01:00.000Z")!
        switch TicketJsonLogicChecker(list: getListWith(rules: JSON(rules)), dataStore: mockDataStore([]), event: mockEvent(), date: now).redeem(ticket: mockTicket()) {
        case .success():
            break
        case .failure(let err):
            XCTFail("Expected success but failed with \(String(describing: err))")
        }
    }
    
    
    func testValidatesMinutesSinceLastEntry() {
        // # Ticket is valid unlimited times, but you always need to wait 3 hours
        
        let rules = """
{"or": [{"<=": [{"var": "minutes_since_last_entry"}, -1]}, {">": [{"var": "minutes_since_last_entry"}, \(60 * 3)]}]}
"""
        // first checkin
        switch TicketJsonLogicChecker(list: getListWith(rules: JSON(rules)), dataStore: mockDataStore([]), event: mockEvent(), date: dateFormatter.date(from: "2020-01-01T10:00:00.000Z")!).redeem(ticket: mockTicket()) {
        case .success():
            break
        case .failure(let err):
            XCTFail("Expected success but failed with \(String(describing: err))")
        }

        // second checkin (too early)
        let ds1 = mockDataStore([
            .init(redemptionRequest: .init(date: dateFormatter.date(from: "2020-01-01T10:00:00.000Z")!, ignoreUnpaid: false, nonce: "", type: "entry"), eventSlug: "", checkInListIdentifier: 2, secret: "")
        ])
        switch TicketJsonLogicChecker(list: getListWith(rules: JSON(rules)), dataStore: ds1, event: mockEvent(), date: dateFormatter.date(from: "2020-01-01T12:55:00.000Z")!).redeem(ticket: mockTicket()) {
        case .success():
            XCTFail("attempted redeem too soon should fail")
        case .failure(let err):
            XCTAssertEqual(err, .rules)
        }

        // second checkin (after 3h)
        let ds2 = mockDataStore([
            .init(redemptionRequest: .init(date: dateFormatter.date(from: "2020-01-01T10:00:00.000Z")!, ignoreUnpaid: false, nonce: "", type: "entry"), eventSlug: "", checkInListIdentifier: 2, secret: "")
        ])
        switch TicketJsonLogicChecker(list: getListWith(rules: JSON(rules)), dataStore: ds2, event: mockEvent(), date: dateFormatter.date(from: "2020-01-01T13:01:00.000Z")!).redeem(ticket: mockTicket()) {
        case .success():
            break
        case .failure(let err):
            XCTFail("Expected success but failed with \(String(describing: err))")
        }

        // third checkin (too soon)
        let ds3 = mockDataStore([
            .init(redemptionRequest: .init(date: dateFormatter.date(from: "2020-01-01T10:00:00.000Z")!, ignoreUnpaid: false, nonce: "", type: "entry"), eventSlug: "", checkInListIdentifier: 2, secret: ""),
            .init(redemptionRequest: .init(date: dateFormatter.date(from: "2020-01-01T13:01:00.000Z")!, ignoreUnpaid: false, nonce: "", type: "entry"), eventSlug: "", checkInListIdentifier: 2, secret: ""),

        ])
        switch TicketJsonLogicChecker(list: getListWith(rules: JSON(rules)), dataStore: ds3, event: mockEvent(), date: dateFormatter.date(from: "2020-01-01T13:01:00.000Z")!).redeem(ticket: mockTicket()) {
        case .success():
            XCTFail("attempted redeem too soon should fail")
        case .failure(let err):
            XCTAssertEqual(err, .rules)
        }
        
        // third checkin (too soon, again)
        let ds4 = mockDataStore([
            .init(redemptionRequest: .init(date: dateFormatter.date(from: "2020-01-01T10:00:00.000Z")!, ignoreUnpaid: false, nonce: "", type: "entry"), eventSlug: "", checkInListIdentifier: 2, secret: ""),
            .init(redemptionRequest: .init(date: dateFormatter.date(from: "2020-01-01T13:01:00.000Z")!, ignoreUnpaid: false, nonce: "", type: "entry"), eventSlug: "", checkInListIdentifier: 2, secret: ""),

        ])
        switch TicketJsonLogicChecker(list: getListWith(rules: JSON(rules)), dataStore: ds4, event: mockEvent(), date: dateFormatter.date(from: "2020-01-01T15:55:00.000Z")!).redeem(ticket: mockTicket()) {
        case .success():
            XCTFail("attempted redeem too soon should fail")
        case .failure(let err):
            XCTAssertEqual(err, .rules)
        }
        
        // third checkin (ok)
        let ds5 = mockDataStore([
            .init(redemptionRequest: .init(date: dateFormatter.date(from: "2020-01-01T10:00:00.000Z")!, ignoreUnpaid: false, nonce: "", type: "entry"), eventSlug: "", checkInListIdentifier: 2, secret: ""),
            .init(redemptionRequest: .init(date: dateFormatter.date(from: "2020-01-01T13:01:00.000Z")!, ignoreUnpaid: false, nonce: "", type: "entry"), eventSlug: "", checkInListIdentifier: 2, secret: ""),

        ])
        switch TicketJsonLogicChecker(list: getListWith(rules: JSON(rules)), dataStore: ds5, event: mockEvent(), date: dateFormatter.date(from: "2020-01-01T16:02:00.000Z")!).redeem(ticket: mockTicket()) {
        case .success():
            break
        case .failure(let err):
            XCTFail("Expected success but failed with \(String(describing: err))")
        }
    }
    
    func testValidatesMinutesSinceFirstEntry() {
        // # Ticket is valid unlimited times, once checked in, you can only come back for 3 hours
        
        let rules = """
{"or": [{"<=": [{"var": "minutes_since_first_entry"}, -1]}, {"<": [{"var": "minutes_since_first_entry"}, \(60 * 3)]}]}
"""
        // first checkin
        switch TicketJsonLogicChecker(list: getListWith(rules: JSON(rules)), dataStore: mockDataStore([]), event: mockEvent(), date: dateFormatter.date(from: "2020-01-01T10:00:00.000Z")!).redeem(ticket: mockTicket()) {
        case .success():
            break
        case .failure(let err):
            XCTFail("Expected success but failed with \(String(describing: err))")
        }

        // second checkin (within 3h of first)
        let ds1 = mockDataStore([
            .init(redemptionRequest: .init(date: dateFormatter.date(from: "2020-01-01T10:00:00.000Z")!, ignoreUnpaid: false, nonce: "", type: "entry"), eventSlug: "", checkInListIdentifier: 2, secret: "")
        ])
        switch TicketJsonLogicChecker(list: getListWith(rules: JSON(rules)), dataStore: ds1, event: mockEvent(), date: dateFormatter.date(from: "2020-01-01T12:55:00.000Z")!).redeem(ticket: mockTicket()) {
        case .success():
            break
        case .failure(let err):
            XCTFail("Expected success but failed with \(String(describing: err))")
        }

        // third checkin (after 3h)
        let ds2 = mockDataStore([
            .init(redemptionRequest: .init(date: dateFormatter.date(from: "2020-01-01T10:00:00.000Z")!, ignoreUnpaid: false, nonce: "", type: "entry"), eventSlug: "", checkInListIdentifier: 2, secret: "")
        ])
        switch TicketJsonLogicChecker(list: getListWith(rules: JSON(rules)), dataStore: ds2, event: mockEvent(), date: dateFormatter.date(from: "2020-01-01T13:01:00.000Z")!).redeem(ticket: mockTicket()) {
        case .success():
            XCTFail("attempted redeem after 3h after first checking should fail")
        case .failure(let err):
            XCTAssertEqual(err, .rules)
        }
    }
    
    
    // MARK: - mocks
    func mockEvent(_ name: String = "event1") -> Event {
        let eventJsonData = testFileContents(name, "json")
        return try! jsonDecoder.decode(Event.self, from: eventJsonData)
    }
    
    func mockSubEvent(_ name: String = "subevent1") -> SubEvent {
        let eventJsonData = testFileContents(name, "json")
        return try! jsonDecoder.decode(SubEvent.self, from: eventJsonData)
    }
    
    var mockItems: [Item] {
        ["item1", "item2"].map({item -> Item in
            let jsonData = testFileContents(item, "json")
            return try! jsonDecoder.decode(Item.self, from: jsonData)
        })
    }
    
    func mockDataStore(_ checkIns: [QueuedRedemptionRequest]) -> DatalessDataStore {
        return MockDataStore(keys: mockEvent().validKeys!.pems, revoked: [], questions: [], items: mockItems, checkIns: checkIns)
    }
    
    func mockTicket(_ item: Identifier = 1, variation: Identifier = 2, subEvent: Identifier = 4) -> TicketJsonLogicChecker.TicketData {
        TicketJsonLogicChecker.TicketData(secret: "1234", eventSlug: mockEvent().slug, item: item, variation: variation, subEvent: subEvent)
    }
    
    class MockDataStore: DatalessDataStore {
        private let keys: [String]
        private let revoked: [String]
        private let questions: [Question]
        private let items: [Item]
        private var checkIns: [QueuedRedemptionRequest]
        
        var stored: [Codable] = []
        
        init(keys: [String], revoked: [String], questions: [Question], items: [Item], checkIns: [QueuedRedemptionRequest]) {
            self.keys = keys
            self.revoked = revoked
            self.questions = questions
            self.items = items
            self.checkIns = checkIns
        }
        
        func getValidKeys(for event: Event) -> Result<[EventValidKey], Error> {
            .success(keys.map({EventValidKey(secret: $0)}))
        }
        
        func getRevokedKeys(for event: Event) -> Result<[RevokedSecret], Error> {
            .success(revoked.map({RevokedSecret(id: 0, secret: $0)}))
        }
        
        func getItem(by identifier: Identifier, in event: Event) -> Item? {
            return items.first(where: {$0.identifier == identifier})
        }
        
        func getQuestions(for item: Item, in event: Event) -> Result<[Question], Error> {
            return .success(questions)
        }
        
        func getQueuedCheckIns(_ secret: String, eventSlug: String) -> Result<[QueuedRedemptionRequest], Error> {
            return .success(checkIns)
        }
        
        func getSubEvents(for event: Event) -> Result<[SubEvent], Error> {
            return .success([])
        }
        
        func store<T>(_ resource: T, for event: Event) where T : Model {
            stored.append(resource)
            if let resp = resource as? QueuedRedemptionRequest {
                checkIns.append(resp)
            }
        }
    }
}
