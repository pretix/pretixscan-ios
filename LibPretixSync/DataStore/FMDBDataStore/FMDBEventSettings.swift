//
//  FMDBEventSettings.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 15/07/2026.
//  Copyright © 2026 rami.io. All rights reserved.
//

import Foundation
import FMDB

extension EventSettings: FMDBModel {
    static var creationQuery = """
    CREATE TABLE IF NOT EXISTS "\(stringName)" (
        "id"   INTEGER NOT NULL UNIQUE,
        "json" TEXT,
        PRIMARY KEY("id")
    );
    """

    static var insertQuery = """
    REPLACE INTO "\(stringName)"("id","json") VALUES (1,?);
    """

    static var selectQuery = """
    SELECT * FROM "\(stringName)" WHERE "id"=1;
    """

    static func from(result: FMResultSet, in database: FMDatabase) -> EventSettings? {
        let json = result.string(forColumn: "json")
        guard let jsonData = json?.data(using: .utf8),
            let settings = try? JSONDecoder.iso8601withFractionsDecoder.decode(EventSettings.self, from: jsonData) else { return nil }
        return settings
    }

    static func store(_ records: [EventSettings], in queue: FMDatabaseQueue) {
        queue.inDatabase { database in
            guard let record = records.last else { return }
            let json = record.toJSONString()

            do {
                try database.executeUpdate(EventSettings.insertQuery, values: [json as Any])
            } catch {
                EventLogger.log(event: "\(error.localizedDescription)", category: .database, level: .fatal, type: .error)
            }
        }
    }

    static func get(in queue: FMDatabaseQueue) -> EventSettings? {
        var settings: EventSettings?

        queue.inDatabase { database in
            if let result = try? database.executeQuery(EventSettings.selectQuery, values: []) {
                while result.next() {
                    settings = EventSettings.from(result: result, in: database)
                }
            }
        }

        return settings
    }
}
