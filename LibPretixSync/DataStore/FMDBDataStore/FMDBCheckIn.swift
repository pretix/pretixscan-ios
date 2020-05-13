//
//  CheckIn.swift
//  pretixSCAN
//
//  Created by Daniel Jilg on 22.05.19.
//  Copyright © 2019 rami.io. All rights reserved.
//
// swiftlint:disable identifier_name

import Foundation
import FMDB

extension CheckIn: FMDBModel {
    static var creationQuery = """
    CREATE TABLE IF NOT EXISTS "\(stringName)" (
    "list"    INTEGER NOT NULL,
    "order_position"    INTEGER  NOT NULL,
    "date"    TEXT  NOT NULL,
    UNIQUE("list", "order_position", "date") ON CONFLICT REPLACE
    );
    """

    static var insertQuery = """
    REPLACE INTO "\(stringName)"("list","order_position","date","type") VALUES (?,?,?,?);
    """

    static let retrieveByOrderPositionQuery = """
    SELECT * FROM "\(stringName)" WHERE order_position=?;
    """

    public static let deleteByOrderPositionQuery = """
    DELETE FROM "\(stringName)" WHERE order_position=?;
    """

    public static let countCheckInsQueryWithPending = """
    SELECT COUNT(*) FROM "\(CheckIn.stringName)"
    LEFT JOIN "\(OrderPosition.stringName)" ON "\(OrderPosition.stringName)".id = "\(CheckIn.stringName)".order_position
    LEFT JOIN "\(Order.stringName)" ON "\(Order.stringName)".code = "\(OrderPosition.stringName)"."order"
    WHERE "\(Order.stringName)".status IN ("n", "p")
    AND "\(CheckIn.stringName)".list = ?
    """

    public static let countCheckInsQueryWithoutPending = """
    SELECT COUNT(*) FROM "\(CheckIn.stringName)"
    LEFT JOIN "\(OrderPosition.stringName)" ON "\(OrderPosition.stringName)".id = "\(CheckIn.stringName)".order_position
    LEFT JOIN "\(Order.stringName)" ON "\(Order.stringName)".code = "\(OrderPosition.stringName)"."order"
    WHERE "\(Order.stringName)".status IN ("p")
    AND "\(CheckIn.stringName)".list = ?
    """

    static func from(result: FMResultSet, in database: FMDatabase) -> CheckIn? {
        guard let date = database.dateFromString(result.string(forColumn: "date")) else {
            EventLogger.log(event: "Date Parsing error in Checkin.from", category: .parsing, level: .warning, type: .fault)
            return nil
        }
        let list = Identifier(result.int(forColumn: "list"))
        return CheckIn(listID: list, date: date, type: result.string(forColumn: "type") ?? "")
    }

    static func deleteCheckIns(for orderPosition: OrderPosition, in queue: FMDatabaseQueue) {
        queue.inDatabase { database in
            do {
                try database.executeUpdate(CheckIn.deleteByOrderPositionQuery, values: [orderPosition.identifier])
            } catch {
                EventLogger.log(event: "\(error.localizedDescription)", category: .database, level: .fatal, type: .error)
            }
        }
    }

    static func store(_ records: [CheckIn], for orderPosition: OrderPosition, in queue: FMDatabaseQueue) {
        // Remove existing checkins, in case something was deleted or overwritten
        deleteCheckIns(for: orderPosition, in: queue)

        // Store new checkins
        queue.inDatabase { database in
            for record in records {
                let list = record.listID as Int
                let order_position = orderPosition.identifier as Int
                let date = database.stringFromDate(record.date)

                do {
                    try database.executeUpdate(CheckIn.insertQuery, values: [
                        list, order_position, date as Any, record.type])
                } catch {
                    EventLogger.log(event: "\(error.localizedDescription)", category: .database, level: .fatal, type: .error)
                }
            }
        }
    }

    static func countCheckIns(of itemID: Int? = nil, variation variationID: Int? = nil,
                              for list: CheckInList, in queue: FMDatabaseQueue) -> Int {

        var resultCount = 0
        let preQuery = list.includePending ? CheckIn.countCheckInsQueryWithPending : CheckIn.countCheckInsQueryWithoutPending
        let itemFilter = itemID == nil ? "" : "\nAND \(OrderPosition.stringName).item = \(itemID!)"
        let variationFilter = variationID == nil ? "" : "\nAND \(OrderPosition.stringName).variation = \(variationID!)"
        let subEventFilter = list.subEvent == nil ? "" : "\nAND \(OrderPosition.stringName).subevent = \(list.subEvent!)"
        let query = preQuery + itemFilter + variationFilter + subEventFilter

        queue.inDatabase { database in
            do {
                let result = try database.executeQuery(query, values: [list.identifier])
                while result.next() {
                    resultCount = Int(result.int(forColumn: "COUNT(*)"))
                }

            } catch {
                EventLogger.log(event: "\(error.localizedDescription)", category: .database, level: .fatal, type: .error)
            }
        }

        return resultCount
    }
}
