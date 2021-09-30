//
//  01_InitialMigration.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 30/09/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation
import FMDB

final class InitialMigration: FMDatabaseMigration {
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
