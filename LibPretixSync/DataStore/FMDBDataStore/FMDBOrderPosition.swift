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
    public static var creationQuery = """
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
    "pseudonymization_id"    TEXT,
    PRIMARY KEY("id")
    );
    """

    public static var insertQuery = """
    REPLACE INTO "\(stringName)"
    ("id", "order", "positionid", "item", "variation", "price", "attendee_name", "attendee_email", "secret", "pseudonymization_id")
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
    """

    public static let searchQuery = """
    SELECT * FROM "\(OrderPosition.stringName)"
    LEFT JOIN "\(Order.stringName)"
    ON "\(OrderPosition.stringName)"."order" = "\(Order.stringName)"."code"
    LEFT JOIN "\(Item.stringName)"
    ON "\(OrderPosition.stringName)"."item" = "\(Item.stringName)"."id"
    WHERE "attendee_name" LIKE ?
    OR "attendee_email" LIKE ?
    OR "email" LIKE ?
    OR "code" LIKE ?;
    """

    public static func from(result: FMResultSet) -> OrderPosition? {
        let identifier = Int(result.int(forColumn: "id"))
        guard let order = result.string(forColumn: "order") else { return nil }
        let positionid = Int(result.int(forColumn: "positionid"))
        let item = Int(result.int(forColumn: "item"))
        let variation = Int(result.int(forColumn: "variation"))
        guard let price = result.string(forColumn: "price") else { return nil }
        let attendee_name = result.string(forColumn: "attendee_name")
        let attendee_email = result.string(forColumn: "attendee_email")
        guard let secret = result.string(forColumn: "secret") else { return nil }
        guard let pseudonymization_id = result.string(forColumn: "pseudonymization_id") else { return nil }

        let orderPosition = OrderPosition(
            identifier: identifier, order: order, positionid: positionid, item: item,
            variation: variation, price: price, attendeeName: attendee_name,
            attendeeEmail: attendee_email, secret: secret,
            pseudonymizationId: pseudonymization_id, checkins: [])
        return orderPosition
    }

    static func store(_ records: [OrderPosition], in queue: FMDatabaseQueue) {
        for record in records {
            CheckIn.store(record.checkins, for: record, in: queue)

            queue.inDatabase { database in
                let identifier = record.identifier as Int
                let order = record.order
                let positionid = record.positionid
                let item = record.item
                let variation = record.variation
                let price = record.price as String
                let attendee_name = record.attendeeName
                let attendee_email = record.attendeeEmail
                let secret = record.secret
                let pseudonymization_id = record.pseudonymizationId

                do {
                    try database.executeUpdate(OrderPosition.insertQuery, values: [
                        identifier, order, positionid, item, variation as Any, price,
                        attendee_name as Any, attendee_email as Any, secret, pseudonymization_id])
                } catch {
                    print(error)
                }
            }
        }
    }
}
