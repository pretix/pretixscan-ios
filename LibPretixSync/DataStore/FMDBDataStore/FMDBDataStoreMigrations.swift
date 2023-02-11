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
    
    func migrateUploads(queue: FMDatabaseQueue) {
        queue.inDatabase { database in
            do {
                try migrateUploads(database: database)
            } catch {
                EventLogger.log(event: "Migration Failed \(error.localizedDescription)", category: .database, level: .fatal, type: .error)
            }
        }
    }
    
    private func migrateUploads(database: FMDatabase) throws {
        print("Migrating Database...")
        print("Current Database Version: \(database.userVersion)")
        
        for migration in uploadMigrations {
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

/// List of event Migrations. Don't forget to add new migrations to this list.
private let migrations: [FMDatabaseMigration] = [
    InitialMigration(),
    MigrationAddAnswersJSON(),
    MigrationAddEntryType(),
    MigrationAddSeatJSON(),
    MigrationAddRevokedSecret(),
    MigrationAddEventValidKeys(),
    MigrationAddAddOnToOrderPosition(),
    MigrationAddBlockedSecret(),
    MigrationAddBlockedToOrderPosition()
]

/// List of upload Migrations. Don't forget to add new migrations to this list.
private let uploadMigrations: [FMDatabaseMigration] = [
    InitialUploadMigration(),
    MigrationQueueAddEntryType(),
    CreateFailedCheckInsTableMigration()
]

/// A Database Migration. fromVersion should be 1 higher than toVersion.
protocol FMDatabaseMigration: AnyObject {
    var fromVersion: UInt32 { get }
    var toVersion: UInt32 { get }
    func performMigration(database: FMDatabase) throws
}
