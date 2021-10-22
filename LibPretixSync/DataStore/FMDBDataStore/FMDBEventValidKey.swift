//
//  FMDBEventKey.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 22/10/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation
import FMDB

extension EventValidKey: FMDBModel {
    static var creationQuery = """
    CREATE TABLE IF NOT EXISTS "\(stringName)" (
        "event_slug"        TEXT NOT NULL,
        "secret"            TEXT NOT NULL
    );
    """
    
    static var insertQuery = """
    INSERT INTO \"\(stringName)\"("event_slug","secret") VALUES (?,?);
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
    
    static func store(_ records: [EventValidKey], eventSlug: String, in queue: FMDatabaseQueue) {
        queue.inDatabase { database in
            do {
                try database.executeUpdate(EventValidKey.deleteAllForEventQuery,
                    values: [eventSlug])
            } catch {
                EventLogger.log(event: "Store EventValidKey: \(error.localizedDescription)", category: .database, level: .error, type: .error)
            }
            
            for record in records {
                let secret = record.secret
                
                do {
                    try database.executeUpdate(Self.insertQuery, values: [eventSlug, secret])
                } catch {
                    EventLogger.log(event: "\(error.localizedDescription)", category: .database, level: .error, type: .error)
                }
            }
        }
    }
    
    static func from(result: FMResultSet, in database: FMDatabase) -> EventValidKey? {
        return EventValidKey(secret: result.string(forColumn: "secret")!)
    }
}
