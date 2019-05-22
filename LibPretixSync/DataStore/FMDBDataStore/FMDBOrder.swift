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
    public static var creationQuery = """
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

    public static var insertQuery = """
    REPLACE INTO "\(stringName)"
    ("code","status","secret","email","checkin_attention",
    "require_approval","json")
    VALUES (?,?,?,?,?,?,?);

    """

    static func store(_ records: [Order], in queue: FMDatabaseQueue) {
        for record in records {
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
                    print(error)
                }
            }
        }
    }
}
