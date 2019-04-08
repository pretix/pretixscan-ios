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
    // MARK: - Initialization
    /// Initialize ConfigStore and APIClient with Device Keys
    func initialize(_ initializationRequest: DeviceInitializationRequest, completionHandler: @escaping (Error?) -> Void)

    // MARK: - Check-In Lists and Events
    // Retrieve all available Events for the current user
    func getEvents(completionHandler: @escaping ([Event]?, Error?) -> Void)

    // Retrieve all available CheckInLists for the current event
    func getCheckinLists(completionHandler: @escaping ([CheckInList]?, Error?) -> Void)

    /// Retrieve Statistics for the currently selected CheckInList
    func getCheckInListStatus(completionHandler: @escaping (CheckInListStatus?, Error?) -> Void)

    // MARK: - Search
    /// Search all OrderPositions within a CheckInList
    func search(query: String, completionHandler: @escaping ([OrderPosition]?, Error?) -> Void)

    // MARK: - Redemption
    /// Check in an attendee, identified by their secret, into the currently configured CheckInList
    ///
    /// - See `RedemptionResponse` for the response returned in the completion handler.
    func redeem(secret: String, force: Bool, ignoreUnpaid: Bool,
                completionHandler: @escaping (RedemptionResponse?, Error?) -> Void)
}
