//
//  01_InitialUploadMigration.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 30/09/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation
import FMDB

final class InitialUploadMigration: FMDatabaseMigration {
    var fromVersion: UInt32 = 0
    var toVersion: UInt32 = 1

    func performMigration(database: FMDatabase) throws {
        try database.executeUpdate(QueuedRedemptionRequest.creationQuery, values: nil)
    }
}
