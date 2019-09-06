//
//  OrderPositionTests.swift
//  PretixScanTests
//
//  Created by Daniel Jilg on 19.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//
// swiftlint:disable type_body_length

import XCTest

class OrderPositionTests: XCTestCase {
    let jsonDecoder = JSONDecoder.iso8601withFractionsDecoder

    let exampleJSON = """
        {
      "id": 1842899,
      "order": "RDTBG",
      "positionid": 1,
      "item": 25643,
      "variation": null,
      "price": "250.00",
      "attendee_name": "Daniel Jilg",
      "attendee_name_parts": {
        "_scheme": "full",
        "full_name": "Daniel Jilg"
      },
      "attendee_email": null,
      "voucher": null,
      "tax_rate": "19.00",
      "tax_value": "39.92",
      "secret": "xmwtyuq5rf3794hwudf7smr6zgmbez9y",
      "addon_to": null,
      "subevent": null,
      "checkins": [],
      "downloads": [
        {
          "output": "pdf",
          "url": "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/orderpositions/1842899/download/pdf/"
        },
        {
          "output": "passbook",
          "url": "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/orderpositions/1842899/download/passbook/"
        }
      ],
      "answers": [],
      "tax_rule": 12107,
      "pseudonymization_id": "DAC7ULNMUB"
    }
    """.data(using: .utf8)!

    let exampleObject = OrderPosition(
        identifier: 1842899, orderCode: "RDTBG", order: nil, positionid: 1, itemIdentifier: 25643, item: nil, variation: nil,
        price: "250.00", attendeeName: "Daniel Jilg", attendeeEmail: nil, secret: "xmwtyuq5rf3794hwudf7smr6zgmbez9y", subEvent: nil,
        pseudonymizationId: "DAC7ULNMUB", checkins: [], answers: []
    )

    let event = Event(name: MultiLingualString.english("Test Event"), slug: "testevent",
                      dateFrom: Date(), hasSubEvents: false)
    let checkInList = CheckInList(identifier: 1, name: "TestCheckInList", allProducts: true,
                                  limitProducts: nil, subEvent: nil, positionCount: 1,
                                  checkinCount: 0, includePending: false)

    func testParsingAll() {
        XCTAssertNoThrow(try jsonDecoder.decode(OrderPosition.self, from: exampleJSON))
        let parsedInstance = try? jsonDecoder.decode(OrderPosition.self, from: exampleJSON)
        XCTAssertEqual(parsedInstance, exampleObject)
    }

    func testAddingOrder() {
        let orderPosition1 = OrderPosition(
            identifier: 1842899, orderCode: "RDTBG", order: nil, positionid: 1, itemIdentifier: 25643,
            item: nil, variation: nil, price: "250.00", attendeeName: "Daniel Jilg", attendeeEmail: nil,
            secret: "xmwtyuq5rf3794hwudf7smr6zgmbez9y", subEvent: nil, pseudonymizationId: "DAC7ULNMUB",
            checkins: [], answers: [])

        let order = Order(code: "ABC", status: .paid, secret: "ABC", email: nil, locale: nil, salesChannel: nil,
                          createdAt: nil, expiresAt: nil, lastModifiedAt: nil, total: nil, comment: nil,
                          checkInAttention: nil, positions: nil, requireApproval: nil)

        let orderPosition2 = OrderPosition(
            identifier: 1842899, orderCode: "RDTBG", order: order, positionid: 1, itemIdentifier: 25643,
            item: nil, variation: nil, price: "250.00", attendeeName: "Daniel Jilg", attendeeEmail: nil,
            secret: "xmwtyuq5rf3794hwudf7smr6zgmbez9y", subEvent: nil, pseudonymizationId: "DAC7ULNMUB",
            checkins: [], answers: [])

        XCTAssertEqual(orderPosition1.adding(order: order), orderPosition2)
    }

    /// Sub Event is wrong
    func testCreateRedemptionResponseCorrectSubEvent() {
        let checkInListWithSubEvent = CheckInList(
            identifier: 1, name: "TestCheckInList", allProducts: true,
            limitProducts: nil, subEvent: 1, positionCount: 1,
            checkinCount: 0, includePending: false)
        let eventWithSubEvents = Event(
            name: MultiLingualString.english("Test Event"),
            slug: "testevent",
            dateFrom: Date(),
            hasSubEvents: true)

        XCTAssertNil(exampleObject.createRedemptionResponse(
            force: false, ignoreUnpaid: false, in: eventWithSubEvents, in: checkInListWithSubEvent))
    }

    /// Order Status has wrong products
    func testCreateRedemptionResponseCorrectProducts() {
        let checkInListLimitProducts = CheckInList(
            identifier: 1,
            name: "TestCheckInList",
            allProducts: false,
            limitProducts: [1, 2],
            subEvent: nil,
            positionCount: 1,
            checkinCount: 0,
            includePending: false)

        let errorResponse = RedemptionResponse(
            status: .error,
            errorReason: .product,
            position: exampleObject,
            lastCheckIn: nil,
            questions: nil, answers: nil)

        XCTAssertEqual(errorResponse, exampleObject.createRedemptionResponse(
            force: false, ignoreUnpaid: false, in: event, in: checkInListLimitProducts))
    }

    /// Order Status Cancelled
    func testCreateRedemptionResponseOrderStatusCancelled() {
        let cancelledOrder = Order.stubOrder(code: "ABC", status: .canceled, secret: "ABC")
        let cancelledOrderPosition = exampleObject.adding(order: cancelledOrder)

        let cancelledResponse = RedemptionResponse(
            status: .error,
            errorReason: .canceled,
            position: cancelledOrderPosition,
            lastCheckIn: nil,
            questions: nil,
            answers: nil)

        XCTAssertEqual(cancelledResponse, cancelledOrderPosition.createRedemptionResponse(
            force: false, ignoreUnpaid: false, in: event, in: checkInList))
    }

    /// Order Status Expired
    func testCreateRedemptionResponseOrderStatusExpired() {
        let expiredOrder = Order.stubOrder(code: "ABC", status: .expired, secret: "ABC")
        let expiredOrderPosition = exampleObject.adding(order: expiredOrder)

        let expiredResponse = RedemptionResponse(
            status: .error,
            errorReason: .canceled,
            position: expiredOrderPosition,
            lastCheckIn: nil,
            questions: nil,
            answers: nil)

        XCTAssertEqual(expiredResponse, expiredOrderPosition.createRedemptionResponse(
            force: false, ignoreUnpaid: false, in: event, in: checkInList))
    }

    /// Order Status Unpaid
    func testCreateRedemptionResponseOrderStatusUnpaid() {
        let unpaidOrder = Order.stubOrder(code: "ABC", status: .pending, secret: "ABC")
        let unpaidOrderPosition = exampleObject.adding(order: unpaidOrder)

        let unpaidResponse = RedemptionResponse(
            status: .error,
            errorReason: .unpaid,
            position: unpaidOrderPosition,
            lastCheckIn: nil,
            questions: nil,
            answers: nil)

        XCTAssertEqual(unpaidResponse, unpaidOrderPosition.createRedemptionResponse(
            force: false, ignoreUnpaid: false, in: event, in: checkInList))
    }

    /// Order Status Unpaid with "Ignore Unpaid Set
    func testCreateRedemptionResponseIgnoreUnpaid() {
        let checkInListWithIncludePending = CheckInList(
            identifier: 1,
            name: "TestCheckInList",
            allProducts: true,
            limitProducts: nil,
            subEvent: nil,
            positionCount: 1,
            checkinCount: 0,
            includePending: true)

        let unpaidOrder = Order.stubOrder(code: "ABC", status: .pending, secret: "ABC")
        let unpaidOrderPosition = exampleObject.adding(order: unpaidOrder)

        let redeemedResponse = RedemptionResponse(
            status: .redeemed,
            errorReason: nil,
            position: unpaidOrderPosition,
            lastCheckIn: nil,
            questions: nil,
            answers: nil)

        XCTAssertEqual(redeemedResponse, unpaidOrderPosition.createRedemptionResponse(
            force: false, ignoreUnpaid: true, in: event, in: checkInListWithIncludePending))
    }

    /// Attendee already checked in
    func testCreateRedemptionResponseAlreadyCheckedIn() {
        let order = Order.stubOrder(code: "ABC", status: .paid, secret: "ABC")

        let lastCheckIn = CheckIn(listID: 1, date: Date())
        let alreadyCheckInOrderPosition = OrderPosition(
            identifier: 1842899, orderCode: "RDTBG", order: order, positionid: 1,
            itemIdentifier: 25643, item: nil, variation: nil,
            price: "250.00", attendeeName: "Daniel Jilg", attendeeEmail: nil,
            secret: "xmwtyuq5rf3794hwudf7smr6zgmbez9y", subEvent: nil,
            pseudonymizationId: "DAC7ULNMUB", checkins: [lastCheckIn],
            answers: [])

        let errorResponse = RedemptionResponse(status: .error, errorReason: .alreadyRedeemed,
                                               position: alreadyCheckInOrderPosition,
                                               lastCheckIn: lastCheckIn,
                                               questions: nil, answers: nil)

        XCTAssertEqual(errorResponse, alreadyCheckInOrderPosition.createRedemptionResponse(
            force: false, ignoreUnpaid: false, in: event, in: checkInList))
    }

    func testCreateRedemptionResponseOpenQuestions() {
        let order = Order.stubOrder(code: "ABC", status: .paid, secret: "ABC")

        let orderPosition = OrderPosition(
            identifier: 1842899, orderCode: "RDTBG", order: order, positionid: 1,
            itemIdentifier: 25643, item: nil, variation: nil,
            price: "250.00", attendeeName: "Daniel Jilg", attendeeEmail: nil,
            secret: "xmwtyuq5rf3794hwudf7smr6zgmbez9y", subEvent: nil,
            pseudonymizationId: "DAC7ULNMUB", checkins: [],
            answers: [])

        let requiredQuestion = Question(
            identifier: 1, question: MultiLingualString.english("Question"),
            type: .oneLineString, isRequired: true, position: 1, items: [], stringIdentifier: "q1",
            askDuringCheckIn: true, isHidden: false, options: [], dependencyQuestion: nil,
            dependencyValue: nil)

        let errorResponse = RedemptionResponse(status: .incomplete, errorReason: nil,
                                               position: orderPosition, lastCheckIn: nil,
                                               questions: [requiredQuestion],
                                               answers: [])
        XCTAssertEqual(errorResponse, orderPosition.createRedemptionResponse(
            force: false, ignoreUnpaid: false, in: event, in: checkInList,
            with: [requiredQuestion]))
    }

    // Questions that are boolean must be answered with YES
    func testCreateRedemptionResponseBoolQuestions() {
        let order = Order.stubOrder(code: "ABC", status: .paid, secret: "ABC")
        let orderPosition = OrderPosition(
            identifier: 1842899, orderCode: "RDTBG", order: order, positionid: 1,
            itemIdentifier: 25643, item: nil, variation: nil,
            price: "250.00", attendeeName: "Daniel Jilg", attendeeEmail: nil,
            secret: "xmwtyuq5rf3794hwudf7smr6zgmbez9y", subEvent: nil,
            pseudonymizationId: "DAC7ULNMUB", checkins: [],
            answers: [])
        let requiredBoolQuestion = Question(
            identifier: 2, question: MultiLingualString.english("Answer yes!"),
            type: .boolean, isRequired: true, position: 2, items: [], stringIdentifier: "q2",
            askDuringCheckIn: true, isHidden: false, options: [], dependencyQuestion: nil,
            dependencyValue: nil)
        let boolErrorResponse = RedemptionResponse(status: .incomplete, errorReason: nil,
                                                   position: orderPosition, lastCheckIn: nil,
                                                   questions: [requiredBoolQuestion],
                                                   answers: [])
        XCTAssertEqual(boolErrorResponse, orderPosition.createRedemptionResponse(
            force: false, ignoreUnpaid: false, in: event, in: checkInList,
            with: [requiredBoolQuestion]))
    }

    // Even for non-required questions, at least an empty answers array has to be passed
    func testCreateRedemptionResponseEmptyQuestions() {
        let order = Order.stubOrder(code: "ABC", status: .paid, secret: "ABC")
        var orderPosition = OrderPosition(
            identifier: 1842899, orderCode: "RDTBG", order: order, positionid: 1,
            itemIdentifier: 25643, item: nil, variation: nil,
            price: "250.00", attendeeName: "Daniel Jilg", attendeeEmail: nil,
            secret: "xmwtyuq5rf3794hwudf7smr6zgmbez9y", subEvent: nil,
            pseudonymizationId: "DAC7ULNMUB", checkins: [],
            answers: nil)
        let optionalQuestion = Question(
            identifier: 3, question: MultiLingualString.english("Why?"), type: .oneLineString,
            isRequired: false, position: 3, items: [], stringIdentifier: "3",
            askDuringCheckIn: true, isHidden: false, options: [], dependencyQuestion: nil,
            dependencyValue: nil)
        let incompleteErrorResponse = RedemptionResponse(
            status: .incomplete, errorReason: nil, position: orderPosition, lastCheckIn: nil,
            questions: [optionalQuestion], answers: nil)

        // No Questions Array given. We expect an "incomplete" response
        XCTAssertEqual(incompleteErrorResponse, orderPosition.createRedemptionResponse(
            force: false, ignoreUnpaid: false, in: event, in: checkInList,
            with: [optionalQuestion]))

        // Empty Questions Array given. We expect the request to go through
        orderPosition.answers = []
        let completeResponse = RedemptionResponse(
            status: .redeemed, errorReason: nil, position: orderPosition, lastCheckIn: nil,
            questions: nil, answers: nil)
        XCTAssertEqual(completeResponse, orderPosition.createRedemptionResponse(
            force: false, ignoreUnpaid: false, in: event, in: checkInList,
            with: [optionalQuestion]))
    }
}
