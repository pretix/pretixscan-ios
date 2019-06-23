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
    PRIMARY KEY("nonce")
    );
    """

    static var insertQuery = """
    REPLACE INTO "\(stringName)"
    ("event", "check_in_list", "secret", "questions_supported",
    "datetime", "force", "ignore_unpaid", "nonce")
    VALUES (?, ?, ?, ?, ?, ?, ?, ?);
    """

    static var numberOfRequestsQuery = """
    SELECT COUNT(*) FROM "\(stringName)";
    """

    static var retrieveOneRequestQuery = """
    SELECT * FROM "\(stringName)" ORDER BY RANDOM() LIMIT 1;
    """

    static var deleteOneRequestQuery = """
    DELETE FROM "\(stringName)" WHERE nonce=?;
    """

    static func from(result: FMResultSet, in database: FMDatabase) -> QueuedRedemptionRequest? {
        guard let event = result.string(forColumn: "event") else { return nil }
        let check_in_list = result.int(forColumn: "check_in_list")
        guard let secret = result.string(forColumn: "secret") else { return nil }
        let questions_supported = result.bool(forColumn: "questions_supported")
        let datetime = database.dateFromString(result.string(forColumn: "datetime"))

        let force = result.bool(forColumn: "force")
        let ignore_unpaid = result.bool(forColumn: "ignore_unpaid")
        guard let nonce = result.string(forColumn: "nonce") else { return nil }

        let redemptionRequest = RedemptionRequest(questionsSupported: questions_supported,
                                                  date: datetime, force: force, ignoreUnpaid: ignore_unpaid, nonce: nonce)
        let queuedRedemptionRequest = QueuedRedemptionRequest(redemptionRequest: redemptionRequest,
                                                              eventSlug: event, checkInListIdentifier: Int(check_in_list), secret: secret)

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

                do {
                    try database.executeUpdate(QueuedRedemptionRequest.insertQuery, values: [
                        event_id, check_in_list_id, secret, questions_supported, datetime as Any, force,
                        ignore_unpaid, nonce])
                } catch {
                    EventLogger.log(event: "\(error.localizedDescription)", category: .database, level: .fatal, type: .error)
                }
            }
        }
    }
}
