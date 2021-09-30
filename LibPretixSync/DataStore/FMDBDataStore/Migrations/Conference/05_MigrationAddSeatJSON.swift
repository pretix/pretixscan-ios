//
//  05_MigrationAddSeatJSON.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 30/09/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation
import FMDB


/// Migrate DB OrderPosition Version 2 to Version 3
final class MigrationAddSeatJSON: FMDatabaseMigration {
    var fromVersion: UInt32 = 4
    var toVersion: UInt32 = 5

    func performMigration(database: FMDatabase) throws {
        database.executeStatements("ALTER TABLE \(OrderPosition.stringName) ADD seat_id INTEGER;")
        database.executeStatements("ALTER TABLE \(OrderPosition.stringName) ADD seat_name TEXT;")
        database.executeStatements("ALTER TABLE \(OrderPosition.stringName) ADD seat_guid TEXT;")
    }
}
