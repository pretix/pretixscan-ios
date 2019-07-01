//
//  FMResultSet+NullableColumns.swift
//  pretixSCAN
//
//  Created by Daniel Jilg on 28.06.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation
import FMDB

extension FMResultSet {
    func nonNullableInt(forColumn column: String) -> Int {
        if let value = nullableInt(forColumn: column) {
            return value
        }

        EventLogger.log(event: "Expected an Int value from Database column \(column), got nil instead!", category: .database,
                        level: .error, type: .error)
        return 0
    }

    func nullableInt(forColumn column: String) -> Int? {
        let value = self.object(forColumn: column)
        if (value as? NSNull) != nil {
            return nil
        } else if value == nil {
            return nil
        }

        return Int(int(forColumn: column))
    }

    func isNull(column: String) -> Bool {
        let value = self.object(forColumn: column)
        if (value as? NSNull) != nil {
            return true
        } else {
            return (value == nil)
        }
    }

    func has(column: String) -> Bool {
        return self.columnNameToIndexMap[column] != nil
    }
}
