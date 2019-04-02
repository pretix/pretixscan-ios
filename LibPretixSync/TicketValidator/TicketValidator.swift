//
//  TicketValidator.swift
//  PretixScan
//
//  Created by Daniel Jilg on 19.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

/// Exposes methods to check the validity of tickets and show event status.
public protocol TicketValidator {
    /// Search all OrderPositions within a CheckInList
    func search(query: String, completionHandler: @escaping ([OrderPosition]?, Error?) -> Void)

    /// Check in an attendee, identified by their secret, into the currently configured CheckInList
    ///
    /// - See `RedemptionResponse` for the response returned in the completion handler.
    func redeem(secret: String, force: Bool, ignoreUnpaid: Bool,
                completionHandler: @escaping (RedemptionResponse?, Error?) -> Void)
}
