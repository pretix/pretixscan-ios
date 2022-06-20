//
//  Order.swift
//  pretixSCAN
//
//  Created by Daniel Jilg on 22.05.19.
//  Copyright © 2019 rami.io. All rights reserved.
//
// swiftlint:disable identifier_name

import Foundation
import FMDB

extension Order: FMDBModel {
    static var creationQuery = """
    CREATE TABLE IF NOT EXISTS "\(stringName)" (
    "code"    TEXT NOT NULL UNIQUE,
    "status"    TEXT,
    "secret"    TEXT,
    "email"    TEXT,
    "checkin_attention"    INTEGER,
    "require_approval"    INTEGER,
    "json"    TEXT,
    PRIMARY KEY("code")
    );
    """

    static var insertQuery = """
    REPLACE INTO "\(stringName)"
    ("code","status","secret","email","checkin_attention",
    "require_approval","json")
    VALUES (?,?,?,?,?,?,?);
    """

    static var searchByCodeQuery = """
    SELECT * FROM "\(stringName)" WHERE code=?;
    """

    static func getOrder(by code: String, in queue: FMDatabaseQueue) -> Order? {
        var order: Order?
        queue.inDatabase { database in
            if let result = try? database.executeQuery(Order.searchByCodeQuery, values: [code]) {
                while result.next() {
                    if let foundItem = Order.from(result: result, in: database) {
                        order = foundItem
                    }
                }
            }

        }

        return order
    }
    
    static func getOrder(secret: String, in queue: FMDatabaseQueue) -> Order? {
        var order: Order?
        queue.inDatabase { database in
            if let result = try? database.executeQuery("""
                                                       SELECT * FROM orders WHERE json LIKE '%"secret":"\(secret.replacingOccurrences(of: "/", with: #"\/"#))"%'
                                                       LIMIT 1
""", values: []) {
                while result.next() {
                    if let foundItem = Order.from(result: result, in: database) {
                        order = foundItem
                    }
                }
            }

        }

        return order
    }

    static func store(_ records: [Order], in queue: FMDatabaseQueue) {
        for record in records {
            // Remove old sub-positions
            OrderPosition.removeOrderPositions(for: record, in: queue)

            if let positions = record.positions {
                OrderPosition.store(positions, in: queue)
            }

            queue.inDatabase { database in
                let code = record.code
                let status = record.status.rawValue
                let secret = record.secret
                let email = record.email
                let checkin_attention = record.checkInAttention?.toInt()
                let require_approval = record.requireApproval?.toInt()
                let json = record.toJSONString()

                do {
                    try database.executeUpdate(Order.insertQuery, values: [
                        code, status, secret, email as Any, checkin_attention as Any,
                        require_approval as Any, json as Any])
                } catch {
                    EventLogger.log(event: "\(error.localizedDescription)", category: .database, level: .fatal, type: .error)
                }
            }
        }
    }

    static func from(result: FMResultSet, in database: FMDatabase) -> Order? {
        let json = result.string(forColumn: "json")
        guard let jsonData = json?.data(using: .utf8),
            let item = try? JSONDecoder.iso8601withFractionsDecoder.decode(Order.self, from: jsonData) else { return nil }
        return item
    }
}
