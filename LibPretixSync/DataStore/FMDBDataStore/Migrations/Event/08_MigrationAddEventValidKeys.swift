//
//  08_MigrationAddEventValidKeys.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 22/10/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation
import FMDB


final class MigrationAddEventValidKeys: FMDatabaseMigration {
    var fromVersion: UInt32 = 7
    var toVersion: UInt32 = 8

    func performMigration(database: FMDatabase) throws {
        try database.executeUpdate(EventValidKey.creationQuery, values: nil)
    }
}
