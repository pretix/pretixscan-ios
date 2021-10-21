//
//  07_MigrationAddRevokedSecret.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 21/10/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation
import FMDB


final class MigrationAddRevokedSecret: FMDatabaseMigration {
    var fromVersion: UInt32 = 5
    var toVersion: UInt32 = 7

    func performMigration(database: FMDatabase) throws {
        try database.executeUpdate(RevokedSecret.creationQuery, values: nil)
    }
}
