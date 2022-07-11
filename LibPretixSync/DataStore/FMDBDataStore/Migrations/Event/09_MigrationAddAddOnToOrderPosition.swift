//
//  09_MigrationAddAddOnToOrderPosition.swift
//  PretixScanTests
//
//  Created by Konstantin Kostov on 08/07/2022.
//  Copyright © 2022 rami.io. All rights reserved.
//

import Foundation
import FMDB

final class MigrationAddAddOnToOrderPosition: FMDatabaseMigration {
    var fromVersion: UInt32 = 8
    var toVersion: UInt32 = 9

    func performMigration(database: FMDatabase) throws {
        database.executeStatements("ALTER TABLE \(OrderPosition.stringName) ADD addon_to INTEGER;")
    }
}
