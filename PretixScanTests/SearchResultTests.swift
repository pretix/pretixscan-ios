//
//  SearchResultTests.swift
//  PretixScanTests
//
//  Created by Konstantin on 16/03/2023.
//  Copyright © 2023 rami.io. All rights reserved.
//

import XCTest
@testable import pretixSCAN

final class SearchResultTests: XCTestCase {
    
    func testResultWithoutCode() {
        let sut = SearchResult(secret: nil, ticket: nil, variation: nil, attendeeName: nil, seat: nil, orderCode: nil, positionId: nil, addonText: nil, status: nil, isRedeemed: false, isRequireAttention: false)
        
        XCTAssertEqual(sut.orderCodeLabel, "--")
    }
    
    func testResultWithCode() {
        let sut = SearchResult(secret: nil, ticket: nil, variation: nil, attendeeName: nil, seat: nil, orderCode: "123", positionId: nil, addonText: nil, status: nil, isRedeemed: false, isRequireAttention: false)
        
        XCTAssertEqual(sut.orderCodeLabel, "123")
    }
    
    func testResultWithCodeAndAttendeeName() {
        let sut = SearchResult(secret: nil, ticket: nil, variation: nil, attendeeName: "Attendee Name", seat: nil, orderCode: "123", positionId: nil, addonText: nil, status: nil, isRedeemed: false, isRequireAttention: false)
        
        XCTAssertEqual(sut.orderCodeLabel, "123 Attendee Name")
    }
}
