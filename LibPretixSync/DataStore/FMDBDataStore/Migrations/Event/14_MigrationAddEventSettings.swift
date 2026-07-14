// Created by Konstantin Kostov on 15/07/2026.
// Copyright (c) 2026. All rights reserved.

import Foundation
import FMDB

final class MigrationAddEventSettings: FMDatabaseMigration {
    var fromVersion: UInt32 = 13
    var toVersion: UInt32 = 14

    func performMigration(database: FMDatabase) throws {
        try database.executeUpdate(EventSettings.creationQuery, values: nil)
    }
}
