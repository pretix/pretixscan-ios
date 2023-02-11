// Created by konstantin on 11/02/2023.
// Copyright (c) 2023. All rights reserved.

import Foundation
import FMDB

final class MigrationAddBlockedToOrderPosition: FMDatabaseMigration {
    var fromVersion: UInt32 = 10
    var toVersion: UInt32 = 11

    func performMigration(database: FMDatabase) throws {
        database.executeStatements("ALTER TABLE \(OrderPosition.stringName) ADD blocked TEXT;")
    }
}
