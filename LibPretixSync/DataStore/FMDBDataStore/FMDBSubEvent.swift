//
//  SubEvent.swift
//  pretixSCAN
//
//  Created by Daniel Jilg on 22.05.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation
import FMDB

extension SubEvent: FMDBModel {
    public static var creationQuery = """
    CREATE TABLE IF NOT EXISTS "\(stringName)" (
    "id"    INTEGER NOT NULL UNIQUE,
    "name"    TEXT,
    "event"    TEXT NOT NULL,
    "json"    TEXT,
    PRIMARY KEY("id")
    );
    """

    public static var insertQuery = """
    REPLACE INTO "\(stringName)"("id","name","event","json") VALUES (?,?,?,?);
    """

    static func store(_ records: [SubEvent], in queue: FMDatabaseQueue) {
        queue.inDatabase { database in
            for record in records {
                let identifier = record.identifier as Int
                let name = record.name.toJSONString()
                let event = record.event
                let json = record.toJSONString()

                do {
                    try database.executeUpdate(SubEvent.insertQuery, values: [
                        identifier, name as Any, event, json as Any])
                } catch {
                    print(error)
                }
            }
        }
    }
}
