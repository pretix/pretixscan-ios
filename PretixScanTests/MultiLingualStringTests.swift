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

    let completeMultiLingualString = MultiLingualString(
        english: "Demo Conference",
        german: "Demokonferenz",
        germanInformal: "Du Demokonferenz",
        spanish: "El Conferencio",
        french: "Le Conférence Demo",
        dutch: "Demo Konferentje",
        dutchInformal: "De Demo Konferentje",
        turkish: "Konferans"
    )

    func testCompleteParsing() {
        let parsedMLString = try? JSONDecoder().decode(MultiLingualString.self, from: completeJSON)
        XCTAssertNotNil(parsedMLString)
        XCTAssertEqual(parsedMLString, completeMultiLingualString)
    }

    func testPartialParsing() {
        let parsedMLString = try? JSONDecoder().decode(MultiLingualString.self, from: partialJSON)
        XCTAssertNotNil(parsedMLString)
        XCTAssertEqual(parsedMLString?.german, "Demokonferenz")
        XCTAssertEqual(parsedMLString?.turkish, "Konferans")
        XCTAssertNil(parsedMLString?.english)
    }

    func testEmptyParsing() {
        let parsedMLString = try? JSONDecoder().decode(MultiLingualString.self, from: emptyJSON)
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

    func testStringRepresentation() {
        var parsedMLString = try? JSONDecoder().decode(MultiLingualString.self, from: completeJSON)
        XCTAssertEqual(parsedMLString?.description, "Demo Conference")

        parsedMLString = try? JSONDecoder().decode(MultiLingualString.self, from: partialJSON)
        XCTAssertEqual(parsedMLString?.description, "Demokonferenz")

        parsedMLString = try? JSONDecoder().decode(MultiLingualString.self, from: emptyJSON)
        XCTAssertEqual(parsedMLString?.description, "(no value)")
    }
}
