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
    func nullableInt(forColumn column: String) -> Int? {
        let value = self.object(forColumn: column)
        if (value as? NSNull) != nil {
            return nil
        } else if value == nil {
            return nil
        }

        return Int(int(forColumn: column))
    }
}
