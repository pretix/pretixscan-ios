//
//  MultiLingualStringTests.swift
//  PretixScanTests
//
//  Created by Daniel Jilg on 15.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import XCTest

class MultiLingualStringTests: XCTestCase {
    let completeJSON = """
        {
        "de": "Demokonferenz",
        "de-informal": "Du Demokonferenz",
        "en": "Demo Conference",
        "es": "El Conferencio",
        "fr": "Le Conférence Demo",
        "nl": "Demo Konferentje",
        "nl-informal": "De Demo Konferentje",
        "tr": "Konferans"
        }
        """.data(using: .utf8)!

    let partialJSON = """
        {
        "de": "Demokonferenz",
        "tr": "Konferans"
        }
        """.data(using: .utf8)!

    let emptyJSON = "{}".data(using: .utf8)!

    let completeMultiLingualString: MultiLingualString = {
        var mls = MultiLingualString.english("Demo Conference")
        mls.german = "Demokonferenz"
        mls.germanInformal = "Du Demokonferenz"
        mls.spanish = "El Conferencio"
        mls.french = "Le Conférence Demo"
        mls.dutch = "Demo Konferentje"
        mls.dutchInformal = "De Demo Konferentje"
        mls.turkish = "Konferans"
        return mls
    }()

    func testCompleteParsing() {
        let parsedMLString = try? JSONDecoder.iso8601withFractionsDecoder.decode(MultiLingualString.self, from: completeJSON)
        XCTAssertNotNil(parsedMLString)
        XCTAssertEqual(parsedMLString, completeMultiLingualString)
    }

    func testPartialParsing() {
        let parsedMLString = try? JSONDecoder.iso8601withFractionsDecoder.decode(MultiLingualString.self, from: partialJSON)
        XCTAssertNotNil(parsedMLString)
        XCTAssertEqual(parsedMLString?.german, "Demokonferenz")
        XCTAssertEqual(parsedMLString?.turkish, "Konferans")
        XCTAssertNil(parsedMLString?.english)
    }

    func testEmptyParsing() {
        let parsedMLString = try? JSONDecoder.iso8601withFractionsDecoder.decode(MultiLingualString.self, from: emptyJSON)
        XCTAssertNotNil(parsedMLString)
        XCTAssertNil(parsedMLString?.english)
        XCTAssertNil(parsedMLString?.german)
        XCTAssertNil(parsedMLString?.germanInformal)
        XCTAssertNil(parsedMLString?.spanish)
        XCTAssertNil(parsedMLString?.french)
        XCTAssertNil(parsedMLString?.dutch)
        XCTAssertNil(parsedMLString?.dutchInformal)
        XCTAssertNil(parsedMLString?.turkish)
    }
}
