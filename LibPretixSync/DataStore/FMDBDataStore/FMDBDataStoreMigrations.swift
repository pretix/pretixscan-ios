//
//  FMDBDataStoreMigrations.swift
//  pretixSCAN
//
//  Created by Daniel Jilg on 29.08.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation
import FMDB

extension FMDBDataStore {
    /// Initialize or migrate a database if necessary
    ///
    /// Database Version Meanings:
    /// - 0: Database not yet initialized
    /// - 1: Version of the database just before we introduced this migration feature
    /// - 2: Answer-JSON
    /// - 3: Entry type
    ///
    /// Further versions count up from there. See the `currentMigration` value for the current highest
    /// version and update it whenever you add migrations.
    func migrate(queue: FMDatabaseQueue) {
        queue.inDatabase { database in
            do {
                try migrate(database: database)
            } catch {
                EventLogger.log(event: "Migration Failed \(error.localizedDescription)", category: .database, level: .fatal, type: .error)
            }
        }
    }

    private func migrate(database: FMDatabase) throws {
        print("Migrating Database...")
        print("Current Database Version: \(database.userVersion)")

        for migration in migrations {
            let migrationName = "\(migration.fromVersion)-\(String(describing: type(of: migration)))"
            guard migration.fromVersion >= database.userVersion else {
                print("Skipping \(migrationName). Already applied.")
                continue
            }

            print("Performing migration \(migrationName)...")
            try migration.performMigration(database: database)
            database.userVersion = migration.toVersion
            print("Finished performing \(migrationName). Database is now at version \(database.userVersion)")
        }
        print("Finished Database Migrations")
    }
}

/// List of all Migrations. Don't forget to add new migrations to this list.
private let migrations: [FMDatabaseMigration] = [
    InitialMigration(),
    MigrationAddAnswersJSON(),
    MigrationAddEntryType()
]

/// A Database Migration. fromVersion should be 1 higher than toVersion.
protocol FMDatabaseMigration: class {
    var fromVersion: UInt32 { get }
    var toVersion: UInt32 { get }
    func performMigration(database: FMDatabase) throws
}

private class InitialMigration: FMDatabaseMigration {
    var fromVersion: UInt32 = 0
    var toVersion: UInt32 = 1

    func performMigration(database: FMDatabase) throws {
        try database.executeUpdate(ItemCategory.creationQuery, values: nil)
        try database.executeUpdate(Item.creationQuery, values: nil)
        try database.executeUpdate(SubEvent.creationQuery, values: nil)
        try database.executeUpdate(Order.creationQuery, values: nil)
        try database.executeUpdate(OrderPosition.creationQuery, values: nil)
        try database.executeUpdate(CheckIn.creationQuery, values: nil)
        try database.executeUpdate(SyncTimeStamp.creationQuery, values: nil)
        try database.executeUpdate(Question.creationQuery, values: nil)
    }
}

/// Migrate DB Version 1 to Version 2
private class MigrationAddAnswersJSON: FMDatabaseMigration {
    var fromVersion: UInt32 = 1
    var toVersion: UInt32 = 2

    func performMigration(database: FMDatabase) throws {
        database.executeStatements("ALTER TABLE \(OrderPosition.stringName) ADD answers_json TEXT;")
    }
}

/// Migrate DB Version 1 to Version 2
private class MigrationAddEntryType: FMDatabaseMigration {
    var fromVersion: UInt32 = 2
    var toVersion: UInt32 = 3

    func performMigration(database: FMDatabase) throws {
        database.executeStatements("ALTER TABLE \(CheckIn.stringName) ADD type TEXT DEFAULT 'entry';")
    }
}
