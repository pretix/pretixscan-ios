//
//  OfflineValidationTests.swift
//  PretixScanTests
//
//  Created by Konstantin Kostov on 12/10/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import XCTest
import CryptoKit
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
    
    func testInvalidLength() throws {
        // arrange
        let qrCode = "E4BibyTSylQOgeKjuMPiTDxi5HXPuTVsx1qCli3IL0143gj0EZXOB9iQInANxRFJTt4Pf9nXnHdB91Qk/RN0L5AIBABSxw2TKFnSUNUCKgjAPAQA"
        let dataStore = MockDataStore(keys: mockEvent.validKeys!.pems, revoked: [], items: [])
        let sut = TicketSignatureChecker(dataStore: dataStore)
        
        // act
        let result = sut.redeem(secret: qrCode, event: mockEvent)
        XCTAssertEqual(result, Result.failure(TicketSignatureChecker.ValidationError.invalid))
    }
    
    func testInvalidLengthByPrefix() throws {
        // arrange
        let qrCode = "AAE4BibyTSylQOgeKjuMPiTDxi5HXPuTVsx1qCli3IL0143gj0EZXOB9iQInANxRFJTt4Pf9nXnHdB91Qk/RN0L5AIBABSxw2TKFnSUNUCKgjAPAQA"
        let dataStore = MockDataStore(keys: mockEvent.validKeys!.pems, revoked: [], items: [])
        let sut = TicketSignatureChecker(dataStore: dataStore)
        
        // act
        let result = sut.redeem(secret: qrCode, event: mockEvent)
        XCTAssertEqual(result, Result.failure(TicketSignatureChecker.ValidationError.invalid))
    }
    
    func testBase64Padding() throws {
        // arrange
        let qrCode = "==E4BibyTSylQOgeKjuMPiTDxi5HXPuTVsx1qCli3IL0143gj0EZXOB9iQInANxRFJTt4Pf9nXnHdB91Qk/RN0L5AIBABSxw2TKFnSUNUCKgjAPAQA"
        let dataStore = MockDataStore(keys: mockEvent.validKeys!.pems, revoked: [], items: [])
        let sut = TicketSignatureChecker(dataStore: dataStore)
        
        // act
        let result = sut.redeem(secret: qrCode, event: mockEvent)
        XCTAssertEqual(result, Result.failure(TicketSignatureChecker.ValidationError.invalid))
    }
    
    func testNonCanonicalEncodingsOfValidTicketAreInvalid() throws {
        let cases: [(name: String, qrCode: String)] = [
            ("padding prefix", "==" + validQrCode),
            ("trailing bytes after signature", "AAAA" + validQrCode),
            ("payload length too long", "E4BibyTSylQOgeKjuMPiTDxi5HXPuTVsx1qCli3IL0143gj0EZXOB9iQInANxRFJTt4Pf9nXnHdB91Qk/RN0L5AIBABSxw2TKFnSUNUCKAEAeAQA"),
            ("signature length too long", "E4BibyTSylQOgeKjuMPiTDxi5HXPuTVsx1qCli3IL0143gj0EZXOB9iQInANxRFJTt4Pf9nXnHdB91Qk/RN0L5AIBABSxw2TKFnSUNUCKAGAPAQA"),
        ]
        let dataStore = MockDataStore(keys: mockEvent.validKeys!.pems, revoked: [], items: [])
        let sut = TicketSignatureChecker(dataStore: dataStore)
        
        for (name, qrCode) in cases {
            XCTAssertEqual(sut.redeem(secret: qrCode, event: mockEvent), .failure(.invalid), name)
        }
    }
    
    func testRevokedTicketInNonCanonicalEncodingIsNotAccepted() throws {
        let dataStore = MockDataStore(keys: mockEvent.validKeys!.pems, revoked: [validQrCode], items: [])
        let sut = TicketSignatureChecker(dataStore: dataStore)
        
        XCTAssertEqual(sut.redeem(secret: validQrCode, event: mockEvent), .failure(.revoked))
        for qrCode in ["==" + validQrCode, "AAAA" + validQrCode] {
            XCTAssertEqual(sut.redeem(secret: qrCode, event: mockEvent), .failure(.invalid), qrCode)
        }
    }
    
    func testMalleatedSignatureIsInvalid() throws {
        let qrCodeWithSPlusGroupOrder = "U4BibyTSylQOgeKjuMPiTXiaz/E4lH/hJ/bb/WNGfr043gj0EZXOB9iQInANxRFJTt4Pf9nXnHdB91Qk/RN0L5AIBABSxw2TKFnSUNUCKAEAPAQA"
        let dataStore = MockDataStore(keys: mockEvent.validKeys!.pems, revoked: [], items: [])
        let sut = TicketSignatureChecker(dataStore: dataStore)
        
        XCTAssertEqual(sut.redeem(secret: qrCodeWithSPlusGroupOrder, event: mockEvent), .failure(.invalid))
    }
    
    func testSignedTicketWithPayloadLongerThan255BytesIsValid() throws {
        let signingKey = Curve25519.Signing.PrivateKey()
        var ticket = Ticket()
        ticket.seed = String(repeating: "s", count: 300)
        ticket.item = 1
        let payload: Data = try ticket.serializedBytes()
        let ticketInformation = TicketInformation(signature: try signingKey.signature(for: payload), payload: payload)
        let qrCode = String(SignedTicketData.encodeBase64(ticketInformation).reversed())
        let dataStore = MockDataStore(keys: [Self.validKey(for: signingKey.publicKey)], revoked: [], items: [])
        let sut = TicketSignatureChecker(dataStore: dataStore)
        
        let result = sut.redeem(secret: qrCode, event: mockEvent)
        
        XCTAssertGreaterThanOrEqual(payload.count, 256)
        let header = try XCTUnwrap(Data(base64Encoded: String(qrCode.reversed())))
        XCTAssertEqual(Array(header[1...2]), [UInt8(payload.count >> 8), UInt8(payload.count & 0xFF)])
        XCTAssertEqual(try result.get().seed, ticket.seed)
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

        func getEventSettings(in event: Event) -> EventSettings? {
            nil
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
    
    let validQrCode = "E4BibyTSylQOgeKjuMPiTDxi5HXPuTVsx1qCli3IL0143gj0EZXOB9iQInANxRFJTt4Pf9nXnHdB91Qk/RN0L5AIBABSxw2TKFnSUNUCKAEAPAQA"
    
    /// Wraps a raw Ed25519 public key as a base64 encoded PEM SubjectPublicKeyInfo, the format of `EventValidKeys.pems`.
    static func validKey(for publicKey: Curve25519.Signing.PublicKey) -> String {
        let subjectPublicKeyInfo = Data([0x30, 0x2a, 0x30, 0x05, 0x06, 0x03, 0x2b, 0x65, 0x70, 0x03, 0x21, 0x00]) + publicKey.rawRepresentation
        let pem = "-----BEGIN PUBLIC KEY-----\n\(subjectPublicKeyInfo.base64EncodedString())\n-----END PUBLIC KEY-----\n"
        return Data(pem.utf8).base64EncodedString()
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
