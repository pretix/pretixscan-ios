// Created by konstantin on 11/02/2023.
// Copyright (c) 2023. All rights reserved.

import Foundation
import FMDB

extension BlockedSecret: FMDBModel {
    static var creationQuery = """
    CREATE TABLE IF NOT EXISTS "\(stringName)" (
        "id"    INTEGER NOT NULL UNIQUE,
        "event_slug"        TEXT NOT NULL,
        "secret"            TEXT NOT NULL,
        "blocked"           INT NOT NULL
    );
    """
    
    static var insertQuery = """
    REPLACE INTO \"\(stringName)\"("id", "event_slug", "secret", "blocked") VALUES (?,?,?,?);
    """
    
    static var searchByEventQuery = """
    SELECT * FROM "\(stringName)" WHERE event_slug=?;
    """

    static var allItemsQuery = """
    SELECT * FROM "\(stringName)";
    """
    
    static var deleteAllForEventQuery = """
    DELETE FROM "\(stringName)" WHERE event_slug=?;
    """
    
    static func store(_ records: [BlockedSecret], eventSlug: String, in queue: FMDatabaseQueue) {
        queue.inDatabase { database in
            do {
                try database.executeUpdate(BlockedSecret.deleteAllForEventQuery,
                    values: [eventSlug])
            } catch {
                EventLogger.log(event: "Store BlockedSecret: \(error.localizedDescription)", category: .database, level: .error, type: .error)
            }
            
            for record in records {
                let id = record.id
                let secret = record.secret
                let blocked = record.blocked
                
                do {
                    try database.executeUpdate(Self.insertQuery, values: [id, eventSlug, secret, blocked])
                } catch {
                    EventLogger.log(event: "\(error.localizedDescription)", category: .database, level: .error, type: .error)
                }
            }
        }
    }
    
    static func from(result: FMResultSet, in database: FMDatabase) -> BlockedSecret? {
        return BlockedSecret(id: Identifier(result.int(forColumn: "id")), secret: result.string(forColumn: "secret")!, blocked: result.bool(forColumn: "blocked"))
    }
}
