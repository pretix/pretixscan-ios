//
//  EntryAnswersCheckerTests.swift
//  PretixScanTests
//
//  Created by Konstantin Kostov on 29/10/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import XCTest
@testable import pretixSCAN

class EntryAnswersCheckerTests: XCTestCase {
    private let jsonDecoder = JSONDecoder.iso8601withFractionsDecoder
    
    
    func testValidatesNoQuestions() throws {
        // arrange
        let dataStore = MockDataStore(keys: mockEvent.validKeys!.pems, revoked: [], questions: [])
        let sut = TicketEntryAnswersChecker(item: mockItems[0], dataStore: dataStore)
        // act
        switch sut.redeem(event: mockEvent, answers: nil) {
        case .success():
            XCTAssert(true)
        case .failure(let err):
            XCTFail("Error \(err)")
        }
    }
    
    func testNoAnswersFailsAndReturnsAllCheckInQuestions() throws {
        // arrange
        let dataStore = MockDataStore(keys: mockEvent.validKeys!.pems, revoked: [], questions: mockQuestions)
        let sut = TicketEntryAnswersChecker(item: mockItems[0], dataStore: dataStore)
        // act
        switch sut.redeem(event: mockEvent, answers: nil) {
        case .success():
            XCTFail("Validation is expected to fail")
        case .failure(let validation):
            XCTAssertEqual(TicketEntryAnswersChecker.ValidationError.incomplete(questions: mockAnswerableQuestions), validation)
        }
    }
    
    func testIncompleteAnswers1() throws {
        // arrange
        let dataStore = MockDataStore(keys: mockEvent.validKeys!.pems, revoked: [], questions: mockQuestions)
        let sut = TicketEntryAnswersChecker(item: mockItems[0], dataStore: dataStore)
        // act
        let answer1 = answer(for: mockQuestions[0].identifier, value: "true")
        switch sut.redeem(event: mockEvent, answers: [answer1]) {
        case .success():
            XCTFail("Validation is expected to fail")
        case .failure(let validation):
            XCTAssertEqual(TicketEntryAnswersChecker.ValidationError.incomplete(questions: [mockQuestions[1], mockQuestions[3]]), validation)
        }
    }
    
    func testIncompleteAnswersForBadBoolean() throws {
        // arrange
        let dataStore = MockDataStore(keys: mockEvent.validKeys!.pems, revoked: [], questions: mockQuestions)
        let sut = TicketEntryAnswersChecker(item: mockItems[0], dataStore: dataStore)
        // act
        let answer1 = answer(for: mockQuestions[0].identifier, value: "false") // valid answer is "True" or "true"
        switch sut.redeem(event: mockEvent, answers: [answer1]) {
        case .success():
            XCTFail("Validation is expected to fail")
        case .failure(let validation):
            XCTAssertEqual(TicketEntryAnswersChecker.ValidationError.incomplete(questions: mockAnswerableQuestions), validation)
        }
    }
    
    func testAllAnswered() throws {
        // arrange
        let dataStore = MockDataStore(keys: mockEvent.validKeys!.pems, revoked: [], questions: mockQuestions)
        let sut = TicketEntryAnswersChecker(item: mockItems[0], dataStore: dataStore)
        // act
        let answer1 = answer(for: mockQuestions[0].identifier, value: "True")
        let answer2 = answer(for: mockQuestions[1].identifier, value: "1")
        switch sut.redeem(event: mockEvent, answers: [answer1, answer2]) {
        case .success():
            XCTAssert(true)
        case .failure(let err):
            XCTFail("Error \(err)")
        }
    }
    
    class MockDataStore: DatalessDataStore {
        private let keys: [String]
        private let revoked: [String]
        private let questions: [Question]
        
        init(keys: [String], revoked: [String], questions: [Question]) {
            self.keys = keys
            self.revoked = revoked
            self.questions = questions
        }
        
        func getValidKeys(for event: Event) -> Result<[EventValidKey], Error> {
            .success(keys.map({EventValidKey(secret: $0)}))
        }
        
        func getRevokedKeys(for event: Event) -> Result<[RevokedSecret], Error> {
            .success(revoked.map({RevokedSecret(id: 0, secret: $0)}))
        }
        
        func getItem(by identifier: Identifier, in event: Event) -> Item? {
            return nil
        }
        
        func getQuestions(for item: Item, in event: Event) -> Result<[Question], Error> {
            return .success(questions)
        }
        
        func getQueuedCheckIns(_ secret: String, eventSlug: String) -> Result<[QueuedRedemptionRequest], Error> {
            return .success([])
        }
        
        func getSubEvents(for event: Event) -> Result<[SubEvent], Error> {
            return .success([])
        }
        
        func getSubEvent(id: Identifier, for event: Event) -> Result<SubEvent?, Error> {
            .success(nil)
        }
        
        func store<T>(_ resource: T, for event: Event) where T : Model {
            
        }
        
        func getOrderCheckIns(_ secret: String, type: String) -> Result<[pretixSCAN.OrderPositionCheckin], Error> {
            return .success([])
        }
    }
    
    
    var mockEvent: Event {
        let eventJsonData = testFileContents("event1", "json")
        return try! jsonDecoder.decode(Event.self, from: eventJsonData)
    }
    
    var mockSignedTicket: SignedTicketData {
        let qrCode = "E4BibyTSylQOgeKjuMPiTDxi5HXPuTVsx1qCli3IL0143gj0EZXOB9iQInANxRFJTt4Pf9nXnHdB91Qk/RN0L5AIBABSxw2TKFnSUNUCKAEAPAQA"
        return SignedTicketData(base64: qrCode, keys: mockEvent.validKeys!)!
    }
    
    var mockDataStore: DatalessDataStore {
        return MockDataStore(keys: mockEvent.validKeys!.pems, revoked: [], questions: mockQuestions)
    }
    
    var mockItems: [Item] {
        ["item1", "item2"].map({item -> Item in
            let jsonData = testFileContents(item, "json")
            return try! jsonDecoder.decode(Item.self, from: jsonData)
        })
    }
    
    var mockQuestions: [Question] {
        ["question1", "question2", "question3", "question4"].map({item -> Question in
            let jsonData = testFileContents(item, "json")
            return try! jsonDecoder.decode(Question.self, from: jsonData)
        })
    }
    
    var mockAnswerableQuestions: [Question] {
        return mockQuestions.filter({$0.askDuringCheckIn})
    }
    
    func answer(for question: Identifier, value: String) -> Answer {
        return Answer(question: question, answer: value, questionStringIdentifier: nil, options: [], optionStringIdentifiers: [])
    }
}
