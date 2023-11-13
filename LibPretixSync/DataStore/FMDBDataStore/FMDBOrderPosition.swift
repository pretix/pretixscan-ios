//
//  OrderPosition.swift
//  pretixSCAN
//
//  Created by Daniel Jilg on 22.05.19.
//  Copyright © 2019 rami.io. All rights reserved.
//
// swiftlint:disable identifier_name

import Foundation
import FMDB

extension OrderPosition: FMDBModel {
    static var creationQuery = """
    CREATE TABLE IF NOT EXISTS "\(stringName)" (
    "id"    INTEGER NOT NULL UNIQUE,
    "order"    TEXT,
    "positionid"    INTEGER,
    "item"    INTEGER,
    "variation"    INTEGER,
    "price"    TEXT,
    "attendee_name"    TEXT,
    "attendee_email"    TEXT,
    "secret"    TEXT,
    "subevent"    INTEGER,
    "pseudonymization_id"    TEXT,
    "blocked"   TEXT,
    PRIMARY KEY("id")
    );
    """

    static var insertQuery = """
    REPLACE INTO "\(stringName)"
    ("id", "order", "positionid", "item", "variation", "price", "attendee_name", "attendee_email",
    "secret", "subevent", "pseudonymization_id", "answers_json", "seat_id", "seat_name", "seat_guid", "blocked", "valid_from", "valid_until")
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
    """

    static let searchQuery = """
    SELECT "\(OrderPosition.stringName)".id AS orderpositionid, "\(OrderPosition.stringName)".secret AS orderpositionsecret, *
    FROM "\(OrderPosition.stringName)"
    LEFT JOIN "\(Order.stringName)"
    ON "\(OrderPosition.stringName)"."order" = "\(Order.stringName)"."code"
    LEFT JOIN "\(Item.stringName)"
    ON "\(OrderPosition.stringName)"."item" = "\(Item.stringName)"."id"
    WHERE "attendee_name" LIKE ?
    OR "attendee_email" LIKE ?
    OR "email" LIKE ?
    OR "code" LIKE ?
    LIMIT 50;
    """

    static let getBySecretQuery =  """
    SELECT "\(OrderPosition.stringName)".id AS orderpositionid, "\(OrderPosition.stringName)".secret AS orderpositionsecret, *
    FROM "\(stringName)"
    WHERE secret = ?;
    """

    static let getByOrderQuery = """
    SELECT * FROM "\(stringName)" WHERE "order"=?;
    """

    static let deleteByOrderQuery = """
    DELETE FROM "\(stringName)" WHERE "order"=?;
    """

    static let countOrderPositionsQueryWithPending = """
    SELECT COUNT(*) FROM "\(OrderPosition.stringName)"
    LEFT JOIN "\(Order.stringName)" ON "\(Order.stringName)".code = "\(OrderPosition.stringName)"."order"
    WHERE "\(Order.stringName)".status IN ("p", "n")
    """

    static let countOrderPositionsQueryWithoutPending = """
    SELECT COUNT(*) FROM "\(OrderPosition.stringName)"
    LEFT JOIN "\(Order.stringName)" ON "\(Order.stringName)".code = "\(OrderPosition.stringName)"."order"
    WHERE "\(Order.stringName)".status IN ("p")
    """

    static func from(result: FMResultSet) -> OrderPosition? {
        let identifier = result.has(column: "orderpositionid")
            ? result.nonNullableInt(forColumn: "orderpositionid")
            : result.nonNullableInt(forColumn: "id")

        let secret = result.has(column: "orderpositionsecret")
            ? result.string(forColumn: "orderpositionsecret")
            : result.string(forColumn: "secret")

        guard let order = result.string(forColumn: "order") else { return nil }
        let positionid = result.nonNullableInt(forColumn: "positionid")
        let item = result.nonNullableInt(forColumn: "item")
        let variation = result.nullableInt(forColumn: "variation")
        guard let price = result.string(forColumn: "price") else { return nil }
        let attendee_name = result.string(forColumn: "attendee_name")
        let attendee_email = result.string(forColumn: "attendee_email")
        let subevent = result.nullableInt(forColumn: "subevent")
        guard let pseudonymization_id = result.string(forColumn: "pseudonymization_id") else { return nil }
        let answersJSON = result.string(forColumn: "answers_json")
        
        let seat_id = result.nullableInt(forColumn: "seat_id")
        let seat_name = result.string(forColumn: "seat_name")
        let seat_guid = result.string(forColumn: "seat_guid")
        let addOntoId = result.nullableInt(forColumn: "addon_to")
        let blockedJSON = result.string(forColumn: "blocked")
        let validFrom = result.date(forColumn: "valid_from")
        let validUntil = result.date(forColumn: "valid_until")

        var answers: [Answer] = []
        if let jsonData = answersJSON?.data(using: .utf8) {
            answers = (try? JSONDecoder.iso8601withFractionsDecoder.decode([Answer].self, from: jsonData)) ?? []
        }
        
        var blocked: [String]? = nil
        if let blockedJson = blockedJSON?.data(using: .utf8) {
            blocked = try? JSONDecoder.iso8601withFractionsDecoder.decode([String].self, from: blockedJson)
        }

        let orderPosition = OrderPosition(
            identifier: identifier, orderCode: order, orderStatus: nil, order: nil, positionid: positionid, itemIdentifier: item, item: nil,
            variation: variation, price: price, attendeeName: attendee_name, attendeeEmail: attendee_email, secret: secret!,
            subEvent: subevent, pseudonymizationId: pseudonymization_id, checkins: [], answers: answers, seat: Seat(seat_id, seat_name, seat_guid), requiresAttention: nil, addonTo: addOntoId, blocked: blocked, validFrom: validFrom, validUntil: validUntil)
        return orderPosition
    }

    static func get(secret: String, in queue: FMDatabaseQueue) -> OrderPosition? {
        var orderPosition: OrderPosition?

        queue.inDatabase { database in
            if let result = try? database.executeQuery(getBySecretQuery, values: [secret]) {
                while result.next() {
                    orderPosition = from(result: result)
                }
            }
        }

        if let orderCode = orderPosition?.orderCode {
            orderPosition?.order = Order.getOrder(by: orderCode, in: queue)
        }

        return orderPosition
    }
    
    static func getAll(secret: String, in queue: FMDatabaseQueue) -> [OrderPosition] {
        var results = [OrderPosition]()

        queue.inDatabase { database in
            do {
                let result = try database.executeQuery(getBySecretQuery, values: [secret])
                while result.next() {
                    if let itemFromResult = OrderPosition.from(result: result) {
                        results.append(itemFromResult)
                    }
                }

            } catch {
                EventLogger.log(event: "\(error.localizedDescription)", category: .database, level: .fatal, type: .error)
            }
        }

        return results
    }

    static func store(_ records: [OrderPosition], in queue: FMDatabaseQueue) {
        for record in records {
            CheckIn.store(record.checkins, for: record, in: queue)

            queue.inDatabase { database in
                let identifier = record.identifier as Int
                let order = record.orderCode
                let positionid = record.positionid
                let item = record.itemIdentifier
                let variation = record.variation
                let price = record.price as String
                let attendee_name = record.attendeeName
                let attendee_email = record.attendeeEmail
                let secret = record.secret
                let subevent = record.subEvent as Int?
                let pseudonymization_id = record.pseudonymizationId
                let seat_id = record.seat?.id
                let seat_name = record.seat?.name
                let seat_guid = record.seat?.seatingPlanid
                let valid_from = record.validFrom
                let valid_until = record.validUntil

                var answersJSON: String?
                if let answers = record.answers, let answersData = try? JSONEncoder.iso8601withFractionsEncoder.encode(answers) {
                    answersJSON = String(data: answersData, encoding: .utf8)
                }
                
                var blockedJSON: String? = nil
                if let blocked = record.blocked, let blockedData = try? JSONEncoder.iso8601withFractionsEncoder.encode(blocked) {
                    blockedJSON = String(data: blockedData, encoding: .utf8)
                }

                do {
                    try database.executeUpdate(OrderPosition.insertQuery, values: [
                        identifier, order, positionid, item, variation as Any, price,
                        attendee_name as Any, attendee_email as Any, secret, subevent as Any, pseudonymization_id,
                        answersJSON as Any, seat_id as Any, seat_name as Any, seat_guid as Any, blockedJSON as Any, valid_from as Any, valid_until as Any])
                } catch {
                    EventLogger.log(event: "\(error.localizedDescription)", category: .database, level: .fatal, type: .error)
                }
            }
        }
    }

    static func removeOrderPositions(for order: Order, in queue: FMDatabaseQueue) {
        // Remove checkins by all affected order positions
        var orderPositionsToDelete = [OrderPosition]()
        queue.inDatabase { database in
            if let result = try? database.executeQuery(OrderPosition.getByOrderQuery, values: [order.code]) {
                while result.next() {
                    if let orderPosition = OrderPosition.from(result: result) {
                        orderPositionsToDelete.append(orderPosition)
                    }
                }
            }
        }

        for orderPositionToDelete in orderPositionsToDelete {
            CheckIn.deleteCheckIns(for: orderPositionToDelete, in: queue)
        }

        // Remove the actual order positions
        queue.inDatabase { database in
            do {
                try database.executeUpdate(OrderPosition.deleteByOrderQuery, values: [order.code])
            } catch {
                EventLogger.log(event: "\(error.localizedDescription)", category: .database, level: .fatal, type: .error)
            }
        }
    }

    static func countOrderPositions(of itemID: Int? = nil, variation variationID: Int? = nil,
                                    for list: CheckInList, in queue: FMDatabaseQueue) -> Int {
        var resultCount = 0

        let preQuery = list.includePending ?
            OrderPosition.countOrderPositionsQueryWithPending : OrderPosition.countOrderPositionsQueryWithoutPending
        let itemFilter = itemID == nil ? "" : "\nAND \(OrderPosition.stringName).item = \(itemID!)"
        let variationFilter = variationID == nil ? "" : "\nAND \(OrderPosition.stringName).variation = \(variationID!)"
        let subEventFilter = list.subEvent == nil ? "" : "\nAND \(OrderPosition.stringName).subevent = \(list.subEvent!)"
        let query = preQuery + itemFilter + variationFilter + subEventFilter

        queue.inDatabase { database in
            do {
                let result = try database.executeQuery(query, values: [])
                while result.next() {
                    resultCount = Int(result.int(forColumn: "COUNT(*)"))
                }

            } catch {
                EventLogger.log(event: "\(error.localizedDescription)", category: .database, level: .fatal, type: .error)
            }
        }

        return resultCount
    }

    func adding(checkIns newCheckIns: [CheckIn]) -> OrderPosition {
        return OrderPosition(
            identifier: identifier, orderCode: orderCode, orderStatus: orderStatus, order: order, positionid: positionid, itemIdentifier: itemIdentifier, item: item,
            variation: variation, price: price, attendeeName: attendeeName, attendeeEmail: attendeeEmail, secret: secret,
            subEvent: subEvent, pseudonymizationId: pseudonymizationId, checkins: newCheckIns, answers: answers, seat: self.seat, requiresAttention: self.requiresAttention, addonTo: self.addonTo, blocked: self.blocked, validFrom: self.validFrom, validUntil: self.validUntil)
    }

    func adding(item: Item?) -> OrderPosition {
        return OrderPosition(
            identifier: identifier, orderCode: orderCode, orderStatus: orderStatus, order: order, positionid: positionid, itemIdentifier: itemIdentifier, item: item,
            variation: variation, price: price, attendeeName: attendeeName, attendeeEmail: attendeeEmail, secret: secret,
            subEvent: subEvent, pseudonymizationId: pseudonymizationId, checkins: checkins, answers: answers, seat: self.seat, requiresAttention: self.requiresAttention, addonTo: self.addonTo, blocked: self.blocked, validFrom: self.validFrom, validUntil: self.validUntil)
    }

    func adding(order: Order?) -> OrderPosition {
        return OrderPosition(
            identifier: identifier, orderCode: orderCode, orderStatus: orderStatus, order: order, positionid: positionid, itemIdentifier: itemIdentifier, item: item,
            variation: variation, price: price, attendeeName: attendeeName, attendeeEmail: attendeeEmail, secret: secret,
            subEvent: subEvent, pseudonymizationId: pseudonymizationId, checkins: checkins, answers: answers, seat: self.seat, requiresAttention: self.requiresAttention, addonTo: self.addonTo, blocked: self.blocked, validFrom: self.validFrom, validUntil: self.validUntil)
    }
    
    func adding(questions: [Question]?) -> OrderPosition {
        var copy = self
        guard let answers = copy.answers, let questions = questions else {
            return copy
        }
        
        copy.answers = answers.map({
            var answerCopy = $0
            switch answerCopy.question {
            case .identifier(let questionId):
                if let knownQuestion = questions.first(where: {q in q.identifier == questionId}) {
                    answerCopy.question = .questionDetail(knownQuestion)
                    return answerCopy
                }
                // sorry, we don't know this question
                return answerCopy
            case .questionDetail(_):
                // already has a question
                return answerCopy
            }
        })
        return copy
    }
    
    func adding(subEvent: SubEvent?) -> OrderPosition {
        var copy = self
        copy.extraSubEvent = subEvent
        return copy
    }
    
    func adding(parentTicket: OrderPosition) -> OrderPosition {
        var copy = self
        
        if copy.attendeeName.isBlank {
            copy.attendeeName = parentTicket.attendeeName
        }
        
        if copy.attendeeEmail.isBlank {
            copy.attendeeEmail = parentTicket.attendeeEmail
        }
        return copy
    }

    func adding(answers: [Answer]?) -> OrderPosition {
        // Take existing answers and overwrite with ones that have been updated
        var mergedAnswers = [Identifier: Answer]()
        for existingAnswer in self.answers ?? [] {
            mergedAnswers[existingAnswer.question.id] = existingAnswer
        }
        for newAnswer in answers ?? [] {
            mergedAnswers[newAnswer.question.id] = newAnswer
        }

        return OrderPosition(
            identifier: identifier, orderCode: orderCode, orderStatus: orderStatus, order: order, positionid: positionid, itemIdentifier: itemIdentifier, item: item,
            variation: variation, price: price, attendeeName: attendeeName, attendeeEmail: attendeeEmail, secret: secret,
            subEvent: subEvent, pseudonymizationId: pseudonymizationId, checkins: checkins, answers: mergedAnswers.values.map { $0 }, seat: self.seat, requiresAttention: self.requiresAttention, addonTo: self.addonTo, blocked: self.blocked, validFrom: self.validFrom, validUntil: self.validUntil)
    }
}

private extension Optional where Wrapped == String {
    /// Returns `true` if the string value is nil or empty
    var isBlank: Bool {
        return self?.isEmpty ?? true
    }
}
