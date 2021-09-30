//
//  04_MigrationQueueAddEntryType.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 30/09/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation
import FMDB

final class MigrationQueueAddEntryType: FMDatabaseMigration {
    var fromVersion: UInt32 = 1
    var toVersion: UInt32 = 4

    func performMigration(database: FMDatabase) throws {
        database.executeStatements("ALTER TABLE \(QueuedRedemptionRequest.stringName) ADD type TEXT DEFAULT 'entry';")
    }
}
