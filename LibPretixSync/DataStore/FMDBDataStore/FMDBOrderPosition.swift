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
    PRIMARY KEY("id")
    );
    """

    static var insertQuery = """
    REPLACE INTO "\(stringName)"
    ("id", "order", "positionid", "item", "variation", "price", "attendee_name", "attendee_email",
    "secret", "subevent", "pseudonymization_id")
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
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
    LIMIT 51;
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

    static func from(result: FMResultSet) -> OrderPosition? {
        let identifier = Int(result.int(forColumn: "orderpositionid"))
        guard let order = result.string(forColumn: "order") else { return nil }
        let positionid = Int(result.int(forColumn: "positionid"))
        let item = Int(result.int(forColumn: "item"))
        let variation = Int(result.int(forColumn: "variation"))
        guard let price = result.string(forColumn: "price") else { return nil }
        let attendee_name = result.string(forColumn: "attendee_name")
        let attendee_email = result.string(forColumn: "attendee_email")
        guard let secret = result.string(forColumn: "orderpositionsecret") else { return nil }
        let subevent = Int(result.int(forColumn: "subevent"))
        guard let pseudonymization_id = result.string(forColumn: "pseudonymization_id") else { return nil }

        let orderPosition = OrderPosition(
            identifier: identifier, orderCode: order, order: nil, positionid: positionid, itemIdentifier: item, item: nil,
            variation: variation, price: price, attendeeName: attendee_name, attendeeEmail: attendee_email, secret: secret,
            subEvent: subevent, pseudonymizationId: pseudonymization_id, checkins: [])
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

        return orderPosition
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

                do {
                    try database.executeUpdate(OrderPosition.insertQuery, values: [
                        identifier, order, positionid, item, variation as Any, price,
                        attendee_name as Any, attendee_email as Any, secret, subevent as Any, pseudonymization_id])
                } catch {
                    print(error)
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
                print(error)
            }
        }
    }

    func adding(checkIns newCheckIns: [CheckIn]) -> OrderPosition {
        return OrderPosition(
            identifier: identifier, orderCode: orderCode, order: order, positionid: positionid, itemIdentifier: itemIdentifier, item: item,
            variation: variation, price: price, attendeeName: attendeeName, attendeeEmail: attendeeEmail, secret: secret,
            subEvent: subEvent, pseudonymizationId: pseudonymizationId, checkins: newCheckIns)
    }

    func adding(item: Item?) -> OrderPosition {
        return OrderPosition(
            identifier: identifier, orderCode: orderCode, order: order, positionid: positionid, itemIdentifier: itemIdentifier, item: item,
            variation: variation, price: price, attendeeName: attendeeName, attendeeEmail: attendeeEmail, secret: secret,
            subEvent: subEvent, pseudonymizationId: pseudonymizationId, checkins: checkins)
    }

    func adding(order: Order?) -> OrderPosition {
        return OrderPosition(
            identifier: identifier, orderCode: orderCode, order: order, positionid: positionid, itemIdentifier: itemIdentifier, item: item,
            variation: variation, price: price, attendeeName: attendeeName, attendeeEmail: attendeeEmail, secret: secret,
            subEvent: subEvent, pseudonymizationId: pseudonymizationId, checkins: checkins)
    }
}
