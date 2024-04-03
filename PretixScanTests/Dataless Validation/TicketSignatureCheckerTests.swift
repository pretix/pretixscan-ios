//
//  OfflineValidationTests.swift
//  PretixScanTests
//
//  Created by Konstantin Kostov on 12/10/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import XCTest
@testable import pretixSCAN


class TicketSignatureCheckerTests: XCTestCase {
    private let jsonDecoder = JSONDecoder.iso8601withFractionsDecoder
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testOfflineSignature() throws {
        // arrange
        let eventJsonData = testFileContents("event1", "json")
        let event = try? jsonDecoder.decode(Event.self, from: eventJsonData)
        guard let event = event else {
            XCTFail("event instance should be arranged")
            return
        }
        guard let eventKeys = event.validKeys else {
            XCTFail("event instance with valid keys should be arranged")
            return
        }
        let qrCode = "E4BibyTSylQOgeKjuMPiTDxi5HXPuTVsx1qCli3IL0143gj0EZXOB9iQInANxRFJTt4Pf9nXnHdB91Qk/RN0L5AIBABSxw2TKFnSUNUCKAEAPAQA"
        
        // act
        let signedTicket = SignedTicketData(base64: qrCode, keys: eventKeys)
        
        // assert
        XCTAssertNotNil(signedTicket)
    }
    
    func testEventHasNoKeys() throws {
        // arrange
        let qrCode = "E4BibyTSylQOgeKjuMPiTDxi5HXPuTVsx1qCli3IL0143gj0EZXOB9iQInANxRFJTt4Pf9nXnHdB91Qk/RN0L5AIBABSxw2TKFnSUNUCKAEAPAQA"
        let dataStore = MockDataStore(keys: [], revoked: [qrCode], items: [])
        let sut = TicketSignatureChecker(dataStore: dataStore)
        
        // act
        let result = sut.redeem(secret: qrCode, event: mockEvent)
        XCTAssertEqual(result, Result.failure(TicketSignatureChecker.ValidationError.noKeys))
    }
    
    func testRevoked() throws {
        // arrange
        let qrCode = "E4BibyTSylQOgeKjuMPiTDxi5HXPuTVsx1qCli3IL0143gj0EZXOB9iQInANxRFJTt4Pf9nXnHdB91Qk/RN0L5AIBABSxw2TKFnSUNUCKAEAPAQA"
        let dataStore = MockDataStore(keys: mockEvent.validKeys!.pems, revoked: [qrCode], items: [])
        let sut = TicketSignatureChecker(dataStore: dataStore)
        
        // act
        let result = sut.redeem(secret: qrCode, event: mockEvent)
        XCTAssertEqual(result, Result.failure(TicketSignatureChecker.ValidationError.revoked))
    }
    
    func testBlocked() throws {
        // arrange
        let qrCode = "E4BibyTSylQOgeKjuMPiTDxi5HXPuTVsx1qCli3IL0143gj0EZXOB9iQInANxRFJTt4Pf9nXnHdB91Qk/RN0L5AIBABSxw2TKFnSUNUCKAEAPAQA"
        let dataStore = MockDataStore(keys: mockEvent.validKeys!.pems, revoked: [], items: [], blocked: [qrCode])
        let sut = TicketSignatureChecker(dataStore: dataStore)
        
        // act
        let result = sut.redeem(secret: qrCode, event: mockEvent)
        XCTAssertEqual(result, Result.failure(TicketSignatureChecker.ValidationError.blocked))
    }
    
    func testInvalid() throws {
        // arrange
        let qrCode = "foo"
        let dataStore = MockDataStore(keys: mockEvent.validKeys!.pems, revoked: ["bar"], items: [])
        let sut = TicketSignatureChecker(dataStore: dataStore)
        
        // act
        let result = sut.redeem(secret: qrCode, event: mockEvent)
        XCTAssertEqual(result, Result.failure(TicketSignatureChecker.ValidationError.invalid))
    }
    
    func testUnknownProductWithLimitProducts() throws {
        // arrange
        let jsonData = testFileContents("list10", "json")
        let list = try! jsonDecoder.decode(CheckInList.self, from: jsonData)
        let dataStore = mockDataStore
        let sut = TicketProductChecker(list: list, dataStore: dataStore)
        // act
        let result = sut.redeem(ticket: mockSignedTicket, event: mockEvent)
        // assert
        XCTAssertEqual(result, Result.failure(TicketProductChecker.ValidationError.product(subEvent: mockSignedTicket.subEvent)))
    }
    
    func testValidWithAllProducts() throws {
        // arrange
        let jsonData = testFileContents("list1", "json")
        let list = try! jsonDecoder.decode(CheckInList.self, from: jsonData)
        let dataStore = mockDataStore
        let sut = TicketProductChecker(list: list, dataStore: dataStore)
        // act
        let result = sut.redeem(ticket: mockSignedTicket, event: mockEvent)
        // assert
        XCTAssertEqual(result, .success(mockItems[0]))
    }
    
    func testInvalidSubEvent() throws {
        // arrange
        let jsonData = testFileContents("list4", "json")
        let list = try! jsonDecoder.decode(CheckInList.self, from: jsonData)
        let dataStore = mockDataStore
        let sut = TicketProductChecker(list: list, dataStore: dataStore)
        // act
        let result = sut.redeem(ticket: mockSignedTicket, event: mockEvent)
        // assert
        XCTAssertEqual(result, Result.failure(TicketProductChecker.ValidationError.invalidProductSubEvent))
    }
    
    
    //MARK: - Mocks
    
    
    class MockDataStore: DatalessDataStore {
        private let keys: [String]
        private let revoked: [String]
        private let blocked: [String]
        private let items: [Item]
        
        init(keys: [String], revoked: [String], items: [Item], blocked: [String] = []) {
            self.keys = keys
            self.revoked = revoked
            self.items = items
            self.blocked = blocked
        }
        
        func getValidKeys(for event: Event) -> Result<[EventValidKey], Error> {
            .success(keys.map({EventValidKey(secret: $0)}))
        }
        
        func getRevokedKeys(for event: Event) -> Result<[RevokedSecret], Error> {
            .success(revoked.map({RevokedSecret(id: 0, secret: $0)}))
        }
        
        func getBlockedKeys(for event: Event) -> Result<[BlockedSecret], Error> {
            .success(blocked.map({BlockedSecret(id: 0, secret: $0, blocked: true)}))
        }
        
        func getItem(by identifier: Identifier, in event: Event) -> Item? {
            return items.first(where: {$0.identifier == identifier})
        }
        
        func getQuestions(for item: Item, in event: Event) -> Result<[Question], Error> {
            return .success([])
        }
        
        func getQueuedCheckIns(_ secret: String, eventSlug: String, listId: Identifier) -> Result<[QueuedRedemptionRequest], Error> {
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
        
        func getOrderCheckIns(_ secret: String, type: String, _ event: Event, listId: Identifier) -> [pretixSCAN.OrderPositionCheckin] {
            return []
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
        return MockDataStore(keys: mockEvent.validKeys!.pems, revoked: [], items: mockItems)
    }
    
    var mockItems: [Item] {
        ["item1", "item2"].map({item -> Item in
            let jsonData = testFileContents(item, "json")
            return try! jsonDecoder.decode(Item.self, from: jsonData)
        })
    }
}
