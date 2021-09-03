//
//  Date+substract.swift
//  Date+substract
//
//  Created by Konstantin Kostov on 03/09/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation

extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
}
