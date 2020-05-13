//
//  LocalizedEnums.swift
//  pretixSCAN
//
//  Created by Daniel Jilg on 01.06.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

extension Order.Status {
    func localizedDescription() -> String {
        switch self {
        case .pending:
            return NSLocalizedString("Pending", comment: "Order Pending")
        case .paid:
            return NSLocalizedString("Paid", comment: "Order Paid")
        case .expired:
            return NSLocalizedString("Expired", comment: "Order Expired")
        case .canceled:
            return NSLocalizedString("Canceled", comment: "Order Canceled")
        }
    }
}

extension RedemptionResponse.ErrorReason {
    func localizedDescription() -> String {
        switch self {
        case .unpaid:
            return NSLocalizedString("Unpaid", comment: "Ticket is Unpaid")
        case .alreadyRedeemed:
            return NSLocalizedString("Already Redeemed", comment: "Ticket is already redeemed")
        case .canceled:
            return NSLocalizedString("Canceled", comment: "Ticket has been canceled")
        case .product:
            return NSLocalizedString("Product", comment: "Ticket is Unpaid")
        case .rules:
            return NSLocalizedString("Not allowed", comment: "Not allowed (custom rule)")
        }
    }
}
