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
    REPLACE INTO "\(stringName)"("list","order_position","date") VALUES (?,?,?);
    """

    static let retrieveByOrderPositionQuery = """
    SELECT * FROM "\(stringName)" WHERE order_position=?;
    """

    public static let deleteByOrderPositionQuery = """
    DELETE FROM "\(stringName)" WHERE order_position=?;
    """

    static func from(result: FMResultSet, in database: FMDatabase) -> CheckIn? {
        guard let date = database.dateFromString(result.string(forColumn: "date")) else {
            print("Date Parsing error in Checkin.from")
            return nil
        }
        let list = Identifier(result.int(forColumn: "list"))
        return CheckIn(listID: list, date: date)
    }

    static func store(_ records: [CheckIn], for orderPosition: OrderPosition, in queue: FMDatabaseQueue) {
        queue.inDatabase { database in
            // Remove existing checkins, in case something was deleted or overwritten
            do {
                try database.executeUpdate(CheckIn.deleteByOrderPositionQuery, values: [orderPosition.identifier])
            } catch {
                print(error)
            }

            // Store new checkins
            for record in records {
                let list = record.listID as Int
                let order_position = orderPosition.identifier as Int
                let date = database.stringFromDate(record.date)

                do {
                    try database.executeUpdate(CheckIn.insertQuery, values: [
                        list, order_position, date as Any])
                } catch {
                    print(error)
                }
            }
        }
    }
}
