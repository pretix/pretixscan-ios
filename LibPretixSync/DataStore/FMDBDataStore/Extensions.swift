//
//  Extensions.swift
//  pretixSCAN
//
//  Created by Daniel Jilg on 22.05.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation
import FMDB

// MARK: Type conversions to and from Sqlite
extension Bool {
    func toInt() -> Int {
        return self ? 1 : 0
    }
}

extension FMDatabase {
    /// FMDB does not allow us to set a global date formatting string, so we'll have to set it
    /// multiple times. This convenience function makes that easier.
    func setupDateFormat() {
        guard !hasDateFormatter() else {
            return
        }
        setDateFormat(FMDatabase.storeableDateFormat("yyyy-MM-dd'T'HH:mm:ssZ"))
    }

    /// Wrwapper for FMDatabase.string(from:) that sets up the correct date formatter and accepts nil values
    func stringFromDate(_ date: Date?) -> String? {
        guard let date = date else { return nil }
        setupDateFormat()
        return string(from: date)
    }

    func dateFromString(_ string: String?) -> Date? {
        guard let string = string else { return nil }
        setupDateFormat()
        return date(from: string)
    }
}
