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

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
