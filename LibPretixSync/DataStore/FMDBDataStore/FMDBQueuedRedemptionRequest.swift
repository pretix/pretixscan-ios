//
//  QueuedRedemptionRequest.swift
//  pretixSCAN
//
//  Created by Daniel Jilg on 22.05.19.
//  Copyright © 2019 rami.io. All rights reserved.
//
// swiftlint:disable identifier_name

import Foundation
import FMDB

extension QueuedRedemptionRequest: FMDBModel {
    static var creationQuery = """
    CREATE TABLE IF NOT EXISTS "\(stringName)" (
    "event"    TEXT NOT NULL,
    "check_in_list"    INTEGER NOT NULL,
    "secret"    TEXT NOT NULL,
    "questions_supported"    INTEGER,
    "datetime"    TEXT,
    "force"    INTEGER,
    "ignore_unpaid"    INTEGER,
    "nonce"    TEXT NOT NULL UNIQUE,
    "json"    TEXT,
    PRIMARY KEY("nonce")
    );
    """

    static var insertQuery = """
    REPLACE INTO "\(stringName)"
    ("event", "check_in_list", "secret", "questions_supported",
    "datetime", "force", "ignore_unpaid", "nonce", "json", "type")
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
    """

    static var numberOfRequestsQuery = """
    SELECT COUNT(*) FROM "\(stringName)";
    """

    static var retrieveOneRequestQuery = """
    SELECT * FROM "\(stringName)" ORDER BY datetime ASC LIMIT 1;
    """

    static var deleteOneRequestQuery = """
    DELETE FROM "\(stringName)" WHERE nonce=?;
    """

    static func from(result: FMResultSet, in database: FMDatabase) -> QueuedRedemptionRequest? {
        guard let json = result.string(forColumn: "json"), let jsonData = json.data(using: .utf8) else { return nil }
        let queuedRedemptionRequest = try? JSONDecoder.iso8601withFractionsDecoder.decode(QueuedRedemptionRequest.self, from: jsonData)
        return queuedRedemptionRequest
    }

    static func store(_ records: [QueuedRedemptionRequest], in queue: FMDatabaseQueue) {
        queue.inDatabase { database in
            for record in records {
                let event_id = record.eventSlug
                let check_in_list_id = record.checkInListIdentifier as Int
                let secret = record.secret
                let questions_supported = record.redemptionRequest.questionsSupported.toInt()
                let datetime = database.stringFromDate(record.redemptionRequest.date)
                let force = record.redemptionRequest.force.toInt()
                let ignore_unpaid = record.redemptionRequest.ignoreUnpaid.toInt()
                let nonce = record.redemptionRequest.nonce
                let json = record.toJSONString() ?? ""
                let type = record.redemptionRequest.type

                do {
                    try database.executeUpdate(QueuedRedemptionRequest.insertQuery, values: [
                        event_id, check_in_list_id, secret, questions_supported, datetime as Any, force,
                        ignore_unpaid, nonce, json, type])
                } catch {
                    EventLogger.log(event: "\(error.localizedDescription)", category: .database, level: .fatal, type: .error)
                }
            }
        }
    }
}
