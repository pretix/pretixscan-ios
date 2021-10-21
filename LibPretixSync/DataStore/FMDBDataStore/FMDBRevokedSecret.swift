//
//  FMDBRevokedSecret.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 21/10/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation
import FMDB

extension RevokedSecret: FMDBModel {
    static var creationQuery = """
    CREATE TABLE IF NOT EXISTS "\(stringName)" (
        "id"    INTEGER NOT NULL UNIQUE,
        "event_slug"        TEXT NOT NULL,
        "secret"            TEXT NOT NULL
    );
    """
    
    static var insertQuery = """
    REPLACE INTO \"\(stringName)\"("id","event_slug","secret") VALUES (?,?,?);
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
    
    static func store(_ records: [RevokedSecret], eventSlug: String, in queue: FMDatabaseQueue) {
        queue.inDatabase { database in
            do {
                try database.executeUpdate(RevokedSecret.deleteAllForEventQuery,
                    values: [eventSlug])
            } catch {
                EventLogger.log(event: "Store RevokedSecret: \(error.localizedDescription)", category: .database, level: .error, type: .error)
            }
            
            for record in records {
                let id = record.id
                let secret = record.secret
                
                do {
                    try database.executeUpdate(Self.insertQuery, values: [id, eventSlug, secret])
                } catch {
                    EventLogger.log(event: "\(error.localizedDescription)", category: .database, level: .error, type: .error)
                }
            }
        }
    }
    
    static func from(result: FMResultSet, in database: FMDatabase) -> RevokedSecret? {
        return RevokedSecret(id: Identifier(result.int(forColumn: "id")), secret: result.string(forColumn: "secret")!)
    }
}
