//
//  SyncTimeStamp.swift
//  pretixSCAN
//
//  Created by Daniel Jilg on 22.05.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation
import FMDB

/// Represents when a certain model has been synced last, if at all
struct SyncTimeStamp: FMDBModel {
    public static let humanReadableName = "Sync Timestamp"
    public static let stringName = "sync_timestamps"

    let model: String
    let lastSyncedAt: String

    static var creationQuery = """
    CREATE TABLE IF NOT EXISTS "\(stringName)" (
    "model"    TEXT NOT NULL UNIQUE,
    "last_synced_at"    TEXT,
    PRIMARY KEY("model")
    );
    """

    static var insertQuery = """
    REPLACE INTO "\(stringName)"
    ("model", "last_synced_at")
    VALUES (?, ?);
    """

    static var getSingleModelQuery = """
    SELECT * FROM \(stringName) WHERE model=?;
    """
}
