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
    ///
    /// Further versions count up from there. See the `currentMigration` value for the current highest
    /// version and update it whenever you add migrations.
    func migrate(queue: FMDatabaseQueue) {
        queue.inDatabase { database in
            do {
                if database.userVersion == 0 {
                    try initializeNew(database: database)
                } else {
                    try migrate(database: database, fromVersion: database.userVersion)
                }
            } catch {
                EventLogger.log(event: "DB Init Failed \(error.localizedDescription)", category: .database, level: .fatal, type: .error)
            }
        }
    }

    private func initializeNew(database: FMDatabase) throws {
        print("Initializing new database...")

        try database.executeUpdate(ItemCategory.creationQuery, values: nil)
        try database.executeUpdate(Item.creationQuery, values: nil)
        try database.executeUpdate(SubEvent.creationQuery, values: nil)
        try database.executeUpdate(Order.creationQuery, values: nil)
        try database.executeUpdate(OrderPosition.creationQuery, values: nil)
        try database.executeUpdate(CheckIn.creationQuery, values: nil)
        try database.executeUpdate(SyncTimeStamp.creationQuery, values: nil)
        try database.executeUpdate(Question.creationQuery, values: nil)

        database.userVersion = UInt32(migrations.count)
    }

    private func migrate(database: FMDatabase, fromVersion: UInt32) throws {
        for migration in migrations[Int(fromVersion + 1)...] {
            print("Performing migration \(String(describing: migration.self))")
            migration.performMigration(database: database)
            print("Finished migration \(String(describing: migration.self))")
        }
    }
}

/// List of all Migrations.
/// This array's `count` property equals the current newest migration version
private let migrations: [FMDatabaseMigration] = [
    ZeroToOneMigration(),
    OneToTwoMigration()
]

/// Abstract Database Migration. Override the performMigration method.
private class FMDatabaseMigration {
    func performMigration(database: FMDatabase) { /* override in subclass */ }
}

// Empty Placeholder Migration
private class ZeroToOneMigration: FMDatabaseMigration {}

/// Migrate DB Version 1 to Version 2
private class OneToTwoMigration: FMDatabaseMigration {
    override func performMigration(database: FMDatabase) {
        database.executeStatements("ALTER TABLE \(OrderPosition.stringName) ADD answers_json TEXT;")
    }
}
