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

    /// Initialize with a configstore
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
        configStore.apiClient?.getEvents(completionHandler: completionHandler)
    }

    public func getSubEvents(event: Event, completionHandler: @escaping ([SubEvent]?, Error?) -> Void) {
        configStore.apiClient?.getSubEvents(event: event, completionHandler: completionHandler)
    }

    public func getCheckinLists(event: Event, completionHandler: @escaping ([CheckInList]?, Error?) -> Void) {
        configStore.apiClient?.getCheckinLists(event: event, completionHandler: completionHandler)
    }

    /// Retrieve Statistics for the currently selected CheckInList
    public func getCheckInListStatus(completionHandler: @escaping (CheckInListStatus?, Error?) -> Void) {
        guard let event = configStore.event, let checkInList = configStore.checkInList else {
            completionHandler(nil, APIError.notConfigured(message: "No Event is set"))
            return
        }

        DispatchQueue.global().async {
            guard let result = self.configStore.dataStore?.getCheckInListStatus(checkInList, in: event) else { return }
            switch result {
            case .success(let checkInListStatus):
                completionHandler(checkInListStatus, nil)
            case .failure(let error):
                completionHandler(nil, error)
            }
        }
    }

    /// Search all OrderPositions within a CheckInList
    public func search(query: String, completionHandler: @escaping ([OrderPosition]?, Error?) -> Void) {
        guard let event = configStore.event else {
            completionHandler(nil, APIError.notConfigured(message: "No Event is set"))
            return
        }
        configStore.dataStore?.searchOrderPositions(query, in: event, completionHandler: completionHandler)
    }

    /// Check in an attendee, identified by OrderPosition, into the currently configured CheckInList
    ///
    /// - See `RedemptionResponse` for the response returned in the completion handler.
    public func redeem(secret: String, force: Bool, ignoreUnpaid: Bool,
                       completionHandler: @escaping (RedemptionResponse?, Error?) -> Void) {
        guard let event = configStore.event else {
            completionHandler(nil, APIError.notConfigured(message: "No Event is set"))
            return
        }

        guard let checkInList = configStore.checkInList else {
            completionHandler(nil, APIError.notConfigured(message: "No CheckInList is set"))
            return
        }

        // Redeem using DataStore
        // A QueuedRedemptionRequest will automatically be generated
        let response = configStore.dataStore?.redeem(secret: secret, force: force, ignoreUnpaid: ignoreUnpaid, in: event, in: checkInList)
        if var response = response {
            guard var position = response.position else {
                completionHandler(response, nil)
                return
            }

            guard let checkInList = self.configStore.checkInList else {
                completionHandler(response, nil)
                return
            }

            guard let dataStore = self.configStore.dataStore else {
                EventLogger.log(event: "Could not retrieve datastore!", category: .configuration, level: .fatal, type: .error)
                completionHandler(response, nil)
                return
            }

            if let event = self.configStore.event {
                position = position.adding(order: dataStore.getOrder(by: position.orderCode, in: event))
                position = position.adding(item: dataStore.getItem(by: position.itemIdentifier, in: event))

                let checkIns = dataStore.getCheckIns(for: position, in: self.configStore.checkInList, in: event)
                position = position.adding(checkIns: checkIns)

                response.position = position

                response.lastCheckIn = position.checkins.filter {
                    $0.listID == checkInList.identifier
                }.first
            }

            completionHandler(response, nil)
        } else {
            completionHandler(nil, APIError.notFound)
        }

        configStore.syncManager.beginSyncingIfAutoSync()
    }
}
