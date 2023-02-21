// Created by konstantin on 11/02/2023.
// Copyright (c) 2023. All rights reserved.

import Foundation
import FMDB

final class MigrationAddBlockedSecret: FMDatabaseMigration {
    var fromVersion: UInt32 = 9
    var toVersion: UInt32 = 10

    func performMigration(database: FMDatabase) throws {
        try database.executeUpdate(BlockedSecret.creationQuery, values: nil)
    }
}
