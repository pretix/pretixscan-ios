//
//  EventTests.swift
//  PretixScanTests
//
//  Created by Daniel Jilg on 15.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import XCTest

class EventTests: XCTestCase {
    let jsonDecoder = JSONDecoder.iso8601withFractionsDecoder

    let exampleJSON = """
        {
            "name": {
                "de": "Demokonferenz",
                "de-informal": "Du Demokonferenz",
                "en": "Demo Conference",
                "es": "El Conferencio",
                "fr": "Le Conférence Demo",
                "nl": "Demo Konferentje",
                "nl-informal": "De Demo Konferentje",
                "tr": "Konferans"
            },
            "slug": "democon",
            "live": true,
            "testmode": false,
            "currency": "EUR",
            "date_from": "2019-12-19T00:00:00+01:00",
            "date_to": null,
            "date_admission": null,
            "is_public": false,
            "presale_start": null,
            "presale_end": null,
            "location": {
                "en": "Augsburg"
            },
            "has_subevents": false,
            "meta_data": {},
            "plugins": [
                "pretix_passbook",
                "pretix.plugins.banktransfer",
                "pretix.plugins.statistics",
                "pretix.plugins.sendmail",
                "pretix_cashpayment",
                "pretix.plugins.reports",
                "pretix.plugins.paypal",
                "pretix_certificates",
                "pretix_servicefees",
                "pretix_bitpay",
                "pretix.plugins.ticketoutputpdf",
                "pretix.plugins.stripe",
                "pretix_facebook",
                "pretix.plugins.pretixdroid",
                "pretix.plugins.badges",
                "pretix_mailchimp"
            ]
        }
        """.data(using: .utf8)!

    let exampleEvent = Event(
        name: MultiLingualString(
            english: "Demo Conference",
            german: "Demokonferenz",
            germanInformal: "Du Demokonferenz",
            spanish: "El Conferencio",
            french: "Le Conférence Demo",
            dutch: "Demo Konferentje",
            dutchInformal: "De Demo Konferentje",
            turkish: "Konferans"
        ),
        slug: "democon",
        dateFrom: Calendar(identifier: .gregorian).date(from: DateComponents(year: 2019, month: 12, day: 19, hour: 0, minute: 0))
    )

    func testParsing() {
        XCTAssertNoThrow(try jsonDecoder.decode(Event.self, from: exampleJSON))
        let parsedEvent = try? jsonDecoder.decode(Event.self, from: exampleJSON)
        XCTAssertEqual(parsedEvent!.name, exampleEvent.name)
        XCTAssertEqual(parsedEvent?.dateFrom, exampleEvent.dateFrom)
        XCTAssertEqual(parsedEvent, exampleEvent)
    }

}
