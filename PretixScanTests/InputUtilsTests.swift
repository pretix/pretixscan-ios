//
//  InputUtilsTests.swift
//  PretixScanTests
//
//  Created by Konstantin Kostov on 15/07/2026.
//  Copyright © 2026 rami.io. All rights reserved.
//

import XCTest
@testable import pretixSCAN

class InputUtilsTests: XCTestCase {
    func testStripsControlCharacters() {
        let input = "AB\u{0000}CD\u{0007}EF"
        let expected = "AB\u{FFFD}CD\u{FFFD}EF"
        XCTAssertEqual(InputUtils.cleanInput(input), expected)
    }

    func testStripsLatin1ECIPrefix1() {
        XCTAssertEqual(InputUtils.cleanInput("\\000001ABC123", sourceType: "barcode"), "ABC123")
    }

    func testStripsLatin1ECIPrefix3() {
        XCTAssertEqual(InputUtils.cleanInput("\\000003ABC123", sourceType: "barcode"), "ABC123")
    }

    func testStripsUTF8ECIPrefix26() {
        XCTAssertEqual(InputUtils.cleanInput("\\000026ABC123", sourceType: "barcode"), "ABC123")
    }

    func testStripsASCIIECIPrefix27() {
        XCTAssertEqual(InputUtils.cleanInput("\\000027ABC123", sourceType: "barcode"), "ABC123")
    }

    func testDoesNotStripECIPrefixForNonBarcodeSourceType() {
        XCTAssertEqual(InputUtils.cleanInput("\\000001ABC123", sourceType: "other"), "\\000001ABC123")
    }

    func testPlainInputPassthrough() {
        XCTAssertEqual(InputUtils.cleanInput("ABC123"), "ABC123")
    }

    func testEmptyStringPassthrough() {
        XCTAssertEqual(InputUtils.cleanInput(""), "")
    }

    func testDefaultSourceTypeIsBarcode() {
        XCTAssertEqual(InputUtils.cleanInput("\\000001ABC123"), "ABC123")
    }
}
