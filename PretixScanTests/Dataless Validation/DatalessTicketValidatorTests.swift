//
//  DatalessTicketValidatorTests.swift
//  PretixScanTests
//
//  Created by Konstantin Kostov on 02/11/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import XCTest
@testable import pretixSCAN


class DatalessTicketValidatorTests: XCTestCase {
    private let jsonDecoder = JSONDecoder.iso8601withFractionsDecoder
    
    func testSignedAndValid() throws {
        // arrange
        let qrCode = "E4BibyTSylQOgeKjuMPiTDxi5HXPuTVsx1qCli3IL0143gj0EZXOB9iQInANxRFJTt4Pf9nXnHdB91Qk/RN0L5AIBABSxw2TKFnSUNUCKAEAPAQA"
        let ds = mockDataStore
        let sut = DatalessTicketValidator(dataStore: ds)
        
        // act
        var resultResponse: RedemptionResponse?
        var resultError: Error?
        let expectation = expectation(description: "Redeem")
        sut.redeem(mockCheckInListAllProducts, mockEvent, qrCode, ignoreUnpaid: false, answers: nil, as: "entry", completionHandler: {(response, err) in
            resultResponse = response
            resultError = err
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertNotNil(resultResponse)
        XCTAssertNil(resultError)
        XCTAssertEqual(resultResponse!.status, .redeemed)
    }
    
    func testQueuedResponseWithForce() throws {
        // arrange
        let qrCode = "E4BibyTSylQOgeKjuMPiTDxi5HXPuTVsx1qCli3IL0143gj0EZXOB9iQInANxRFJTt4Pf9nXnHdB91Qk/RN0L5AIBABSxw2TKFnSUNUCKAEAPAQA"
        let ds = mockDataStore
        let sut = DatalessTicketValidator(dataStore: ds)
        
        // act
        var resultResponse: RedemptionResponse?
        var resultError: Error?
        let expectation = expectation(description: "Redeem")
        sut.redeem(mockCheckInListAllProducts, mockEvent, qrCode, ignoreUnpaid: false, answers: nil, as: "entry", completionHandler: {(response, err) in
            resultResponse = response
            resultError = err
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 5, handler: nil)
        
        let queued = (try? ds.getQueuedCheckIns(qrCode, eventSlug: mockEvent.slug).get())?.first
        
        XCTAssertNotNil(queued?.redemptionRequest)
        XCTAssertTrue(queued!.redemptionRequest.force)
    }
    
    func testSignedAndValidMissingAnswers() throws {
        // arrange
        let qrCode = "E4BibyTSylQOgeKjuMPiTDxi5HXPuTVsx1qCli3IL0143gj0EZXOB9iQInANxRFJTt4Pf9nXnHdB91Qk/RN0L5AIBABSxw2TKFnSUNUCKAEAPAQA"
        let ds = mockDataStoreWithQuestions
        let sut = DatalessTicketValidator(dataStore: ds)
        
        // act
        var resultResponse: RedemptionResponse?
        var resultError: Error?
        let expectation1 = expectation(description: "Redeem")
        sut.redeem(mockCheckInListAllProducts, mockEvent, qrCode, ignoreUnpaid: false, answers: nil, as: "entry", completionHandler: {(response, err) in
            resultResponse = response
            resultError = err
            expectation1.fulfill()
        })
        
        waitForExpectations(timeout: 5, handler: nil)
        
        let answer1 = answer(for: mockQuestions[0].identifier, value: "True")
        
        let expectation2 = expectation(description: "Redeem 2")
        sut.redeem(mockCheckInListAllProducts, mockEvent, qrCode, ignoreUnpaid: false, answers: [answer1], as: "entry", completionHandler: {(response, err) in
            resultResponse = response
            resultError = err
            expectation2.fulfill()
        })
        
        waitForExpectations(timeout: 5, handler: nil)
        
        
        XCTAssertNotNil(resultResponse)
        XCTAssertNil(resultError)
        XCTAssertNotNil(resultResponse!.questions)
        XCTAssertEqual(resultResponse!.status, .incomplete)
        XCTAssertEqual(resultResponse!.questions, [mockAnswerableQuestions[1]])
    }
    
    func testSignedAndValidCheckInAttention() throws {
        // arrange
        let qrCode = "E4BibyTSylQOgeKjuMPiTDxi5HXPuTVsx1qCli3IL0143gj0EZXOB9iQInANxRFJTt4Pf9nXnHdB91Qk/RN0L5AIBABSxw2TKFnSUNUCKAEAPAQA"
        let ds = mockDataStore
        let sut = DatalessTicketValidator(dataStore: ds)
        
        // act
        var resultResponse: RedemptionResponse?
        var resultError: Error?
        let expectation = expectation(description: "Redeem")
        sut.redeem(mockCheckInListAllProducts, mockEvent, qrCode, ignoreUnpaid: false, answers: nil, as: "entry", completionHandler: {(response, err) in
            resultResponse = response
            resultError = err
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertNotNil(resultResponse)
        XCTAssertNil(resultError)
        XCTAssertEqual(resultResponse!.status, .redeemed)
        XCTAssertEqual(resultResponse!.isRequireAttention, true)
    }
    
    func testSignedAndRevoked() throws {
        // arrange
        let qrCode = "E4BibyTSylQOgeKjuMPiTDxi5HXPuTVsx1qCli3IL0143gj0EZXOB9iQInANxRFJTt4Pf9nXnHdB91Qk/RN0L5AIBABSxw2TKFnSUNUCKAEAPAQA"
        let ds = mockDataStoreRevoked
        let sut = DatalessTicketValidator(dataStore: ds)
        
        // act
        var resultResponse: RedemptionResponse?
        var resultError: Error?
        let expectation = expectation(description: "Redeem")
        sut.redeem(mockCheckInListAllProducts, mockEvent, qrCode, ignoreUnpaid: false, answers: nil, as: "entry", completionHandler: {(response, err) in
            resultResponse = response
            resultError = err
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertNotNil(resultResponse)
        XCTAssertNil(resultError)
        XCTAssertEqual(resultResponse!.status, .error)
        XCTAssertEqual(resultResponse!.errorReason, .revoked)
    }
    
    func testSignedUnknownProduct() throws {
        // arrange
        let qrCode = "OUmw2Ro3YOMQ4ktAlAIsDVe4Xsr1KXla/0SZVN34qIZWtUX0hx1DXDHxaCatGTNzOeCMjHQABR5E6ESCOOx1g7AIkBhVkdDdJJTVSZWCKAEAPAQA"
        let ds = mockDataStore
        let sut = DatalessTicketValidator(dataStore: ds)
        
        // act
        var resultResponse: RedemptionResponse?
        var resultError: Error?
        let expectation = expectation(description: "Redeem")
        sut.redeem(mockCheckInListAllProducts, mockEvent, qrCode, ignoreUnpaid: false, answers: nil, as: "entry", completionHandler: {(response, err) in
            resultResponse = response
            resultError = err
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertNotNil(resultResponse)
        XCTAssertNil(resultError)
        XCTAssertEqual(resultResponse!.status, .error)
        XCTAssertEqual(resultResponse!.errorReason, .product)
    }
    
    func testSignedInvalidSignature() throws {
        // arrange
        let qrCode = "EFAKEyTSylQOgeKjuMPiTDxi5HXPuTVsx1qCli3IL0143gj0EZXOB9iQInANxRFJTt4Pf9nXnHdB91Qk/RN0L5AIBABSxw2TKFnSUNUCKAEAPAQA"
        let ds = mockDataStore
        let sut = DatalessTicketValidator(dataStore: ds)
        
        // act
        var resultResponse: RedemptionResponse?
        var resultError: Error?
        let expectation = expectation(description: "Redeem")
        sut.redeem(mockCheckInListAllProducts, mockEvent, qrCode, ignoreUnpaid: false, answers: nil, as: "entry", completionHandler: {(response, err) in
            resultResponse = response
            resultError = err
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertNotNil(resultResponse)
        XCTAssertNil(resultError)
        XCTAssertEqual(resultResponse!.status, .error)
        XCTAssertEqual(resultResponse!.errorReason, .invalid)
    }
    
    func testNoSecondEntry() throws {
        // arrange
        let qrCode = "E4BibyTSylQOgeKjuMPiTDxi5HXPuTVsx1qCli3IL0143gj0EZXOB9iQInANxRFJTt4Pf9nXnHdB91Qk/RN0L5AIBABSxw2TKFnSUNUCKAEAPAQA"
        let ds = mockDataStore
        let sut = DatalessTicketValidator(dataStore: ds)
        
        // act
        var resultResponse: RedemptionResponse?
        var resultError: Error?
        let expectation1 = expectation(description: "Redeem")
        sut.redeem(mockCheckInListAllProducts, mockEvent, qrCode, ignoreUnpaid: false, answers: nil, as: "entry", completionHandler: {(response, err) in
            resultResponse = response
            resultError = err
            expectation1.fulfill()
        })
        
        waitForExpectations(timeout: 5, handler: nil)
        
        let expectation2 = expectation(description: "Redeem2")
        sut.redeem(mockCheckInListAllProducts, mockEvent, qrCode, ignoreUnpaid: false, answers: nil, as: "entry", completionHandler: {(response, err) in
            resultResponse = response
            resultError = err
            expectation2.fulfill()
        })
        
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertNotNil(resultResponse)
        XCTAssertNil(resultError)
        XCTAssertEqual(resultResponse!.status, .error)
        XCTAssertEqual(resultResponse!.errorReason, .alreadyRedeemed)
    }
    
    func testEntryAfterExit() throws {
        // arrange
        let qrCode = "E4BibyTSylQOgeKjuMPiTDxi5HXPuTVsx1qCli3IL0143gj0EZXOB9iQInANxRFJTt4Pf9nXnHdB91Qk/RN0L5AIBABSxw2TKFnSUNUCKAEAPAQA"
        let ds = mockDataStore
        let sut = DatalessTicketValidator(dataStore: ds)
        
        // act
        var resultResponse: RedemptionResponse?
        var resultError: Error?
        let expectation1 = expectation(description: "Entry")
        sut.redeem(mockCheckInListAllProducts, mockEvent, qrCode, ignoreUnpaid: false, answers: nil, as: "entry", completionHandler: {(response, err) in
            resultResponse = response
            resultError = err
            expectation1.fulfill()
        })
        
        waitForExpectations(timeout: 5, handler: nil)
        
        let expectation2 = expectation(description: "Exit")
        sut.redeem(mockCheckInListAllProducts, mockEvent, qrCode, ignoreUnpaid: false, answers: nil, as: "exit", completionHandler: {(response, err) in
            resultResponse = response
            resultError = err
            expectation2.fulfill()
        })
        
        waitForExpectations(timeout: 5, handler: nil)
        
        let expectation3 = expectation(description: "Entry 2")
        sut.redeem(mockCheckInListAllProducts, mockEvent, qrCode, ignoreUnpaid: false, answers: nil, as: "entry", completionHandler: {(response, err) in
            resultResponse = response
            resultError = err
            expectation3.fulfill()
        })
        
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertNotNil(resultResponse)
        XCTAssertNil(resultError)
        XCTAssertEqual(resultResponse!.status, .redeemed)
    }
    
    func testNoEntryAfterExit() throws {
        // arrange
        let qrCode = "E4BibyTSylQOgeKjuMPiTDxi5HXPuTVsx1qCli3IL0143gj0EZXOB9iQInANxRFJTt4Pf9nXnHdB91Qk/RN0L5AIBABSxw2TKFnSUNUCKAEAPAQA"
        let ds = mockDataStore
        let sut = DatalessTicketValidator(dataStore: ds)
        
        // act
        var resultResponse: RedemptionResponse?
        var resultError: Error?
        let expectation1 = expectation(description: "Entry")
        sut.redeem(mockCheckInListAllProducts, mockEvent, qrCode, ignoreUnpaid: false, answers: nil, as: "entry", completionHandler: {(response, err) in
            resultResponse = response
            resultError = err
            expectation1.fulfill()
        })
        
        waitForExpectations(timeout: 5, handler: nil)
        
        let expectation2 = expectation(description: "Exit")
        sut.redeem(mockCheckInListAllProducts, mockEvent, qrCode, ignoreUnpaid: false, answers: nil, as: "exit", completionHandler: {(response, err) in
            resultResponse = response
            resultError = err
            expectation2.fulfill()
        })
        
        waitForExpectations(timeout: 5, handler: nil)
        
        let expectation3 = expectation(description: "Entry 2")
        sut.redeem(mockCheckInListNoEntryAfterExit, mockEvent, qrCode, ignoreUnpaid: false, answers: nil, as: "entry", completionHandler: {(response, err) in
            resultResponse = response
            resultError = err
            expectation3.fulfill()
        })
        
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertNotNil(resultResponse)
        XCTAssertNil(resultError)
        XCTAssertEqual(resultResponse!.status, .error)
        XCTAssertEqual(resultResponse!.errorReason, .alreadyRedeemed)
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
        
        func store<T>(_ resource: T, for event: Event) where T : Model {
            stored.append(resource)
            if let resp = resource as? QueuedRedemptionRequest {
                checkIns.append(resp)
            }
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
        return MockDataStore(keys: mockEvent.validKeys!.pems, revoked: [], questions: [], items: mockItems, checkIns: [])
    }
    
    var mockDataStoreWithQuestions: DatalessDataStore {
        return MockDataStore(keys: mockEvent.validKeys!.pems, revoked: [], questions: mockQuestions, items: mockItems, checkIns: [])
    }
    
    var mockDataStoreRevoked: DatalessDataStore {
        return MockDataStore(keys: mockEvent.validKeys!.pems, revoked: ["E4BibyTSylQOgeKjuMPiTDxi5HXPuTVsx1qCli3IL0143gj0EZXOB9iQInANxRFJTt4Pf9nXnHdB91Qk/RN0L5AIBABSxw2TKFnSUNUCKAEAPAQA"], questions: [], items: mockItems, checkIns: [])
    }
    
    var mockItems: [Item] {
        ["item1", "item2"].map({item -> Item in
            let jsonData = testFileContents(item, "json")
            return try! jsonDecoder.decode(Item.self, from: jsonData)
        })
    }
    
    var mockQuestions: [Question] {
        ["question1", "question2", "question3"].map({item -> Question in
            let jsonData = testFileContents(item, "json")
            return try! jsonDecoder.decode(Question.self, from: jsonData)
        })
    }
    
    var mockCheckInLists: [CheckInList] {
        ["list1", "list2", "list4", "list5", "list6"].map({item -> CheckInList in
            let jsonData = testFileContents(item, "json")
            return try! jsonDecoder.decode(CheckInList.self, from: jsonData)
        })
    }
    
    var mockCheckInListAllProducts: CheckInList {
        mockCheckInLists[3]
    }
    
    var mockCheckInListNoEntryAfterExit: CheckInList {
        mockCheckInLists[4]
    }
    
    var mockAnswerableQuestions: [Question] {
        return mockQuestions.filter({$0.askDuringCheckIn})
    }
    
    func answer(for question: Identifier, value: String) -> Answer {
        return Answer(question: question, answer: value, questionStringIdentifier: nil, options: [], optionStringIdentifiers: [])
    }

}
