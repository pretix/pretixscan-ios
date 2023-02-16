// Created by konstantin on 16/02/2023.
// Copyright (c) 2023. All rights reserved.

import Foundation
import FMDB

final class MigrationAddValidToFrom: FMDatabaseMigration {
    var fromVersion: UInt32 = 11
    var toVersion: UInt32 = 12

    func performMigration(database: FMDatabase) throws {
        database.executeStatements("ALTER TABLE \(OrderPosition.stringName) ADD valid_from DATE;")
        database.executeStatements("ALTER TABLE \(OrderPosition.stringName) ADD valid_until DATE;")
    }
}
