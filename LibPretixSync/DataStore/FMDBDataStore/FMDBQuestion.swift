//
//  FMDBQuestion.swift
//  pretixSCAN
//
//  Created by Daniel Jilg on 01.07.19.
//  Copyright © 2019 rami.io. All rights reserved.
//
// swiftlint:disable identifier_name

import Foundation
import FMDB

extension Question: FMDBModel {
    static var creationQuery = """
    CREATE TABLE IF NOT EXISTS "\(stringName)" (
        "id"    INTEGER NOT NULL,
        "question"    TEXT NOT NULL,
        "type"    TEXT NOT NULL,
        "required"    INTEGER,
        "position" INTEGER,
        "identifier"    TEXT,
        "ask_during_checkin"    INTEGER,
        "dependency_question"    TEXT,
        "dependency_value"    TEXT,
        "json"    TEXT NOT NULL
    );
    """

    static var insertQuery = """
    REPLACE INTO "\(stringName)"
    ("id", "question", "type", "required", "position",
    "identifier", "ask_during_checkin", "dependency_question", "dependency_value", "json")
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
    """

    static let checkInQuestionsWithItemQuery = """
    SELECT * FROM "\(stringName)" WHERE ask_during_checkin=? ORDER BY position;
    """

    static func from(result: FMResultSet, in database: FMDatabase) -> Question? {
        guard let json = result.string(forColumn: "json"), let jsonData = json.data(using: .utf8) else { return nil }
        guard let question = try? JSONDecoder.iso8601withFractionsDecoder.decode(Question.self, from: jsonData) else { return nil }

        return question
    }

    static func store(_ records: [Question], in queue: FMDatabaseQueue) {
        queue.inDatabase { database in
            for record in records {
                let id = record.identifier
                let question = record.question.toJSONString()
                let type = record.type.rawValue
                let required = record.isRequired
                let position = record.position
                let identifer = record.stringIdentifier
                let ask_during_checkin = record.askDuringCheckIn
                let dependency_question = record.dependencyQuestion
                let dependency_value = record.dependencyValue
                let json = record.toJSONString()!

                do {
                    try database.executeUpdate(Question.insertQuery, values: [
                        id, question as Any, type, required, position, identifer, ask_during_checkin,
                        dependency_question as Any, dependency_value as Any, json])
                } catch {
                    EventLogger.log(event: "\(error.localizedDescription)", category: .database, level: .error, type: .error)
                }
            }
        }
    }
}
