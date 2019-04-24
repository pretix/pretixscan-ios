//
//  OfflineTicketValidator.swift
//  PretixScan
//
//  Created by Daniel Jilg on 08.04.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

/// Uses the `DataStore` provided by `ConfigStore` to attempt all operations without a network connection present.
public class OfflineTicketValidator: TicketValidator {
    private let configStore: ConfigStore

    public init(configStore: ConfigStore) {
        self.configStore = configStore
    }

    /// Initialize ConfigStore and APIClient with Device Keys
    ///
    /// Note: This always uses the API directly. Offline Mode is not supported.
    public func initialize(_ initializationRequest: DeviceInitializationRequest, completionHandler: @escaping (Error?) -> Void) {
        configStore.apiClient?.initialize(initializationRequest, completionHandler: completionHandler)
    }

    // Retrieve all available Events for the current user
    public func getEvents(completionHandler: @escaping ([Event]?, Error?) -> Void) {
        let events = configStore.dataStore?.getEvents()
        completionHandler(events, nil)
    }

    // Retrieve all available CheckInLists for the specified event
    public func getCheckinLists(completionHandler: @escaping ([CheckInList]?, Error?) -> Void) {
        guard let event = configStore.event else {
            completionHandler(nil, APIError.notConfigured(message: "No Event is set"))
            return
        }
        let checkInLists = configStore.dataStore?.getCheckInLists(for: event)
        completionHandler(checkInLists, nil)
    }

    /// Retrieve Statistics for the currently selected CheckInList
    public func getCheckInListStatus(completionHandler: @escaping (CheckInListStatus?, Error?) -> Void) {
        configStore.apiClient?.getCheckInListStatus(completionHandler: completionHandler)
    }

    /// Search all OrderPositions within a CheckInList
    public func search(query: String, completionHandler: @escaping ([OrderPosition]?, Error?) -> Void) {
        guard let event = configStore.event else {
            completionHandler(nil, APIError.notConfigured(message: "No Event is set"))
            return
        }
        let foundOrderPositions = configStore.dataStore?.searchOrderPositions(query, in: event)
        completionHandler(foundOrderPositions, nil)
    }

    /// Check in an attendee, identified by OrderPosition, into the currently configured CheckInList
    ///
    /// - See `RedemptionResponse` for the response returned in the completion handler.
    public func redeem(secret: String, force: Bool, ignoreUnpaid: Bool,
                       completionHandler: @escaping (RedemptionResponse?, Error?) -> Void) {
        configStore.apiClient?.redeem(secret: secret, force: force, ignoreUnpaid: ignoreUnpaid, completionHandler: completionHandler)
    }
}
