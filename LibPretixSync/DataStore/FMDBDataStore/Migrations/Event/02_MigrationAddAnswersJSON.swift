//
//  02_MigrationAddAnswersJSON.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 30/09/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation
import FMDB

/// Migrate DB OrderPosition Version 1 to Version 2
final class MigrationAddAnswersJSON: FMDatabaseMigration {
    var fromVersion: UInt32 = 1
    var toVersion: UInt32 = 2

    func performMigration(database: FMDatabase) throws {
        database.executeStatements("ALTER TABLE \(OrderPosition.stringName) ADD answers_json TEXT;")
    }
}
