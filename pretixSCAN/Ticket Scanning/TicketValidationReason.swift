//
//  TicketValidationReason.swift
//  TicketValidationReason
//
//  Created by Konstantin Kostov on 28/07/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation

public enum TicketValidationReason: String {
    case unknown
    case notRedeemed = "R01"
    case redeemedRequest = "R02"
}


extension RedemptionResponse {
    /// Creates a copy of the redemption response and applies the provided `TicketValidationReason`
    func with(reason: TicketValidationReason) -> RedemptionResponse {
        var copy = self
        copy._validationReason = reason
        return copy
    }
}
