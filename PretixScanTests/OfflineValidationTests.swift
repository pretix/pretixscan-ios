//
//  OfflineValidationTests.swift
//  PretixScanTests
//
//  Created by Konstantin Kostov on 12/10/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import XCTest
@testable import pretixSCAN


class OfflineValidationTests: XCTestCase {
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
    
    var mockSignedTicket: SignedTicketData {
        let eventJsonData = testFileContents("event1", "json")
        let event = try! jsonDecoder.decode(Event.self, from: eventJsonData)
        let qrCode = "E4BibyTSylQOgeKjuMPiTDxi5HXPuTVsx1qCli3IL0143gj0EZXOB9iQInANxRFJTt4Pf9nXnHdB91Qk/RN0L5AIBABSxw2TKFnSUNUCKAEAPAQA"
        return SignedTicketData(base64: qrCode, keys: event.validKeys!)!
    }

    func testEventHasNoKeys() throws {
        // arrange
        let eventJsonData = testFileContents("event1", "json")
        let event = try! jsonDecoder.decode(Event.self, from: eventJsonData)
        let qrCode = "E4BibyTSylQOgeKjuMPiTDxi5HXPuTVsx1qCli3IL0143gj0EZXOB9iQInANxRFJTt4Pf9nXnHdB91Qk/RN0L5AIBABSxw2TKFnSUNUCKAEAPAQA"
        let dataStore = MockDataStore(keys: [], revoked: [qrCode])
        let sut = TicketSignatureValidator(dataStore: dataStore)
        
        // act
        let result = sut.redeem(secret: qrCode, event: event)
        XCTAssertEqual(result, Result.failure(TicketSignatureValidator.ValidationError.noKeys))
    }
    
    func testRevoked() throws {
        // arrange
        let eventJsonData = testFileContents("event1", "json")
        let event = try! jsonDecoder.decode(Event.self, from: eventJsonData)
        let qrCode = "E4BibyTSylQOgeKjuMPiTDxi5HXPuTVsx1qCli3IL0143gj0EZXOB9iQInANxRFJTt4Pf9nXnHdB91Qk/RN0L5AIBABSxw2TKFnSUNUCKAEAPAQA"
        let dataStore = MockDataStore(keys: event.validKeys!.pems, revoked: [qrCode])
        let sut = TicketSignatureValidator(dataStore: dataStore)
        
        // act
        let result = sut.redeem(secret: qrCode, event: event)
        XCTAssertEqual(result, Result.failure(TicketSignatureValidator.ValidationError.revoked))
    }
    
    func testInvalid() throws {
        // arrange
        let eventJsonData = testFileContents("event1", "json")
        let event = try! jsonDecoder.decode(Event.self, from: eventJsonData)
        let qrCode = "foo"
        let dataStore = MockDataStore(keys: event.validKeys!.pems, revoked: ["bar"])
        let sut = TicketSignatureValidator(dataStore: dataStore)
        
        // act
        let result = sut.redeem(secret: qrCode, event: event)
        XCTAssertEqual(result, Result.failure(TicketSignatureValidator.ValidationError.invalid))
    }
    
    func testUnknownProductWithLimitProducts() throws {
        let jsonData = testFileContents("list2", "json")
        let list = try! jsonDecoder.decode(CheckInList.self, from: jsonData)
        let sut = TicketProductValidator(list: list)
        let result = sut.redeem(ticket: mockSignedTicket)
        XCTAssertEqual(result, Result.failure(TicketProductValidator.ValidationError.product))
    }
    
    func testValidWithAllProducts() throws {
        let jsonData = testFileContents("list1", "json")
        let list = try! jsonDecoder.decode(CheckInList.self, from: jsonData)
        let sut = TicketProductValidator(list: list)
        let result = sut.redeem(ticket: mockSignedTicket)
        XCTAssertEqual(result, .success(mockSignedTicket))
    }
    
    func testInvalidSubEvent() throws {
        let jsonData = testFileContents("list4", "json")
        let list = try! jsonDecoder.decode(CheckInList.self, from: jsonData)
        let sut = TicketProductValidator(list: list)
        let result = sut.redeem(ticket: mockSignedTicket)
        XCTAssertEqual(result, Result.failure(TicketProductValidator.ValidationError.invalidProductSubEvent))
    }
    
    class MockDataStore: SignedDataStore {
        private let keys: [String]
        private let revoked: [String]
        
        init(keys: [String], revoked: [String]) {
            self.keys = keys
            self.revoked = revoked
        }
        
        func getValidKeys(for event: Event) -> Result<[EventValidKey], Error> {
            .success(keys.map({EventValidKey(secret: $0)}))
        }
        
        func getRevokedKeys(for event: Event) -> Result<[RevokedSecret], Error> {
            .success(revoked.map({RevokedSecret(id: 0, secret: $0)}))
        }
    }
}
