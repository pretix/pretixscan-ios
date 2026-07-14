//
//  FMDBReusableMedium.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 14/07/2026.
//  Copyright © 2026 rami.io. All rights reserved.
//

import Foundation
import FMDB

extension ReusableMedium: FMDBModel {
    static var creationQuery = """
    CREATE TABLE IF NOT EXISTS "\(stringName)" (
        "id"          INTEGER NOT NULL UNIQUE,
        "type"        TEXT NOT NULL,
        "identifier"  TEXT NOT NULL,
        "active"      INTEGER NOT NULL,
        "expires"     TEXT,
        "json"        TEXT,
        PRIMARY KEY("id")
    );
    """

    static var creationQueryIndex = """
    CREATE INDEX IF NOT EXISTS "reusablemedia_identifier" ON "\(stringName)" ("identifier");
    """

    static var creationQueryOrderPositions = """
    CREATE TABLE IF NOT EXISTS "reusablemedia_orderpositions" (
        "medium_id"        INTEGER NOT NULL,
        "orderposition_id" INTEGER NOT NULL,
        PRIMARY KEY("medium_id", "orderposition_id")
    );
    """

    static var insertQuery = """
    REPLACE INTO "\(stringName)"("id","type","identifier","active","expires","json") VALUES (?,?,?,?,?,?);
    """

    static var deleteOrderPositionsQuery = """
    DELETE FROM "reusablemedia_orderpositions" WHERE "medium_id"=?;
    """

    static var insertOrderPositionQuery = """
    REPLACE INTO "reusablemedia_orderpositions"("medium_id","orderposition_id") VALUES (?,?);
    """

    static var searchByIdentifierAndTypeQuery = """
    SELECT * FROM "\(stringName)" WHERE "identifier"=? AND "type"=?;
    """

    /// Finds a medium by identifier and type, restricted to media that have at least one order position
    /// linked within this event's database. A medium row present without any linked positions in this
    /// event's database will not be found.
    static var searchByIdentifierAndTypeWithLinkedPositionQuery = """
    SELECT DISTINCT "\(stringName)".* FROM "\(stringName)"
    JOIN "reusablemedia_orderpositions" ON "reusablemedia_orderpositions"."medium_id" = "\(stringName)"."id"
    JOIN "\(OrderPosition.stringName)" ON "\(OrderPosition.stringName)"."id" = "reusablemedia_orderpositions"."orderposition_id"
    WHERE "\(stringName)"."identifier"=? AND "\(stringName)"."type"=?;
    """

    static var linkedOrderPositionsQuery = """
    SELECT "\(OrderPosition.stringName)".id AS orderpositionid, "\(OrderPosition.stringName)".secret AS orderpositionsecret, *
    FROM "reusablemedia_orderpositions"
    JOIN "\(OrderPosition.stringName)"
    ON "reusablemedia_orderpositions"."orderposition_id" = "\(OrderPosition.stringName)"."id"
    WHERE "reusablemedia_orderpositions"."medium_id" = ?
    ORDER BY "\(OrderPosition.stringName)"."id" ASC;
    """

    static var existsByLinkedOrderPositionQuery = """
    SELECT 1 FROM "reusablemedia_orderpositions" WHERE "orderposition_id" = ? LIMIT 1;
    """

    static func from(result: FMResultSet, in database: FMDatabase) -> ReusableMedium? {
        let json = result.string(forColumn: "json")
        guard let jsonData = json?.data(using: .utf8),
            let medium = try? JSONDecoder.iso8601withFractionsDecoder.decode(ReusableMedium.self, from: jsonData) else { return nil }
        return medium
    }

    static func store(_ records: [ReusableMedium], in queue: FMDatabaseQueue) {
        queue.inDatabase { database in
            for record in records {
                let identifier = record.identifier
                let type = record.type
                let mediumIdentifier = record.mediumIdentifier
                let active = record.active.toInt()
                let expires = database.stringFromDate(record.expires)
                let json = record.toJSONString()

                do {
                    try database.executeUpdate(ReusableMedium.insertQuery, values: [
                        identifier, type, mediumIdentifier, active, expires as Any, json as Any])
                } catch {
                    EventLogger.log(event: "\(error.localizedDescription)", category: .database, level: .fatal, type: .error)
                }

                do {
                    try database.executeUpdate(ReusableMedium.deleteOrderPositionsQuery, values: [identifier])
                } catch {
                    EventLogger.log(event: "\(error.localizedDescription)", category: .database, level: .fatal, type: .error)
                }

                for orderPositionIdentifier in record.linkedOrderPositions {
                    do {
                        try database.executeUpdate(ReusableMedium.insertOrderPositionQuery, values: [identifier, orderPositionIdentifier])
                    } catch {
                        EventLogger.log(event: "\(error.localizedDescription)", category: .database, level: .fatal, type: .error)
                    }
                }
            }
        }
    }

    static func get(identifier: String, type: String, in queue: FMDatabaseQueue) -> ReusableMedium? {
        var medium: ReusableMedium?

        queue.inDatabase { database in
            if let result = try? database.executeQuery(ReusableMedium.searchByIdentifierAndTypeQuery, values: [identifier, type]) {
                while result.next() {
                    medium = ReusableMedium.from(result: result, in: database)
                }
            }
        }

        return medium
    }

    static func getForCheckIn(identifier: String, type: String, in queue: FMDatabaseQueue) -> ReusableMedium? {
        var medium: ReusableMedium?

        queue.inDatabase { database in
            if let result = try? database.executeQuery(ReusableMedium.searchByIdentifierAndTypeWithLinkedPositionQuery, values: [identifier, type]) {
                while result.next() {
                    medium = ReusableMedium.from(result: result, in: database)
                }
            }
        }

        return medium
    }

    static func hasLinkedMedium(orderPositionIdentifier: Identifier, in queue: FMDatabaseQueue) -> Bool {
        var exists = false

        queue.inDatabase { database in
            if let result = try? database.executeQuery(ReusableMedium.existsByLinkedOrderPositionQuery, values: [orderPositionIdentifier]) {
                exists = result.next()
                result.close()
            }
        }

        return exists
    }

    static func getOrderPositions(linkedToMedium medium: ReusableMedium, in queue: FMDatabaseQueue) -> [OrderPosition] {
        var results = [OrderPosition]()

        queue.inDatabase { database in
            if let result = try? database.executeQuery(ReusableMedium.linkedOrderPositionsQuery, values: [medium.identifier]) {
                while result.next() {
                    if let orderPosition = OrderPosition.from(result: result) {
                        results.append(orderPosition)
                    }
                }
            }
        }

        return results
    }
}
