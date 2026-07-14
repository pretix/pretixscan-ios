// Created by Konstantin Kostov on 14/07/2026.
// Copyright (c) 2026. All rights reserved.

import Foundation
import FMDB

final class MigrationAddReusableMedium: FMDatabaseMigration {
    var fromVersion: UInt32 = 12
    var toVersion: UInt32 = 13

    func performMigration(database: FMDatabase) throws {
        try database.executeUpdate(ReusableMedium.creationQuery, values: nil)
        try database.executeUpdate(ReusableMedium.creationQueryIndex, values: nil)
        try database.executeUpdate(ReusableMedium.creationQueryOrderPositions, values: nil)
    }
}
