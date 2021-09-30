//
//  06_CreateFailedCheckInsTableMigration.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 30/09/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation
import FMDB

final class CreateFailedCheckInsTableMigration: FMDatabaseMigration {
    var fromVersion: UInt32 = 5
    var toVersion: UInt32 = 6

    func performMigration(database: FMDatabase) throws {
        try database.executeUpdate(FailedCheckIn.creationQuery, values: nil)
    }
}
