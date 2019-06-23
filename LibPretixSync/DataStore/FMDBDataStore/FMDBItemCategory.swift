//
//  ItemCategory.swift
//  pretixSCAN
//
//  Created by Daniel Jilg on 22.05.19.
//  Copyright © 2019 rami.io. All rights reserved.
//
// swiftlint:disable identifier_name

import Foundation
import FMDB

extension ItemCategory: FMDBModel {
    static var creationQuery = """
    CREATE TABLE IF NOT EXISTS "\(stringName)" (
    "id"    INTEGER NOT NULL UNIQUE,
    "name"    TEXT,
    "internal_name"    TEXT,
    "description"    TEXT,
    "position"    INTEGER,
    "is_addon"    INTEGER,
    PRIMARY KEY("id")
    );
    """

    static var insertQuery = """
    REPLACE INTO "\(stringName)"
    ("id", "name", "internal_name", "description", "position", "is_addon")
    VALUES (?, ?, ?, ?, ?, ?);
    """

    static func store(_ itemCategories: [ItemCategory], in queue: FMDatabaseQueue) {
        queue.inDatabase { database in
            for itemCategory in itemCategories {
                let identifier = itemCategory.identifier as Int
                let name = itemCategory.name.toJSONString()
                let internal_name = itemCategory.internalName
                let description = itemCategory.description?.toJSONString()
                let position = itemCategory.position
                let is_addon = itemCategory.isAddon

                do {
                    try database.executeUpdate(ItemCategory.insertQuery, values: [
                        identifier, name as Any, internal_name as Any, description as Any, position, is_addon])
                } catch {
                    EventLogger.log(event: "\(error.localizedDescription)", category: .database, level: .fatal, type: .error)
                }
            }
        }
    }
}
