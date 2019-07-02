//
//  OnlineTicketValidator.swift
//  PretixScan
//
//  Created by Daniel Jilg on 19.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

/// Uses the APIClient directly to check the validity of tickets.
///
/// Does not add anything to DataStore's queue, but instead returns errors if no network available
public class OnlineTicketValidator: TicketValidator {
    private let configStore: ConfigStore

    /// Initialize with a configstore
    public init(configStore: ConfigStore) {
        self.configStore = configStore
    }

    public func initialize(_ initializationRequest: DeviceInitializationRequest, completionHandler: @escaping (Error?) -> Void) {
        configStore.apiClient?.initialize(initializationRequest, completionHandler: completionHandler)
    }

    public func getEvents(completionHandler: @escaping ([Event]?, Error?) -> Void) {
        configStore.apiClient?.getEvents(completionHandler: completionHandler)
    }

    public func getSubEvents(event: Event, completionHandler: @escaping ([SubEvent]?, Error?) -> Void) {
        configStore.apiClient?.getSubEvents(event: event, completionHandler: completionHandler)
    }

    public func getCheckinLists(event: Event, completionHandler: @escaping ([CheckInList]?, Error?) -> Void) {
        configStore.apiClient?.getCheckinLists(event: event, completionHandler: completionHandler)
    }

    public func getQuestions(for item: Item, event: Event, completionHandler: @escaping ([Question]?, Error?) -> Void) {
        // TODO
    }

    /// Search all OrderPositions within a CheckInList
    public func search(query: String, completionHandler: @escaping ([OrderPosition]?, Error?) -> Void) {
        configStore.apiClient?.getSearchResults(query: query) { orderPositions, error in
            guard let orderPositions = orderPositions else {
                completionHandler(nil, error)
                return
            }

            var enhancedOrderPositions = [OrderPosition]()
            for orderPosition in orderPositions {
                if let event =  self.configStore.event,
                    let item = self.configStore.dataStore?.getItem(by: orderPosition.itemIdentifier, in: event) {
                    enhancedOrderPositions.append(
                        orderPosition.adding(item: item)
                            .adding(order: self.configStore.dataStore?.getOrder(by: orderPosition.orderCode, in: event))
                    )
                } else {
                    enhancedOrderPositions.append(orderPosition)
                }

            }
            completionHandler(enhancedOrderPositions, error)
        }
    }

    /// Check in an attendee, identified by OrderPosition, into the currently configured CheckInList
    ///
    /// - See `RedemptionResponse` for the response returned in the completion handler.
    public func redeem(secret: String, force: Bool, ignoreUnpaid: Bool,
                       completionHandler: @escaping (RedemptionResponse?, Error?) -> Void) {
        configStore.apiClient?.redeem(secret: secret, force: force, ignoreUnpaid: ignoreUnpaid) { redemptionResponse, error in
            guard var redemptionResponse = redemptionResponse else {
                completionHandler(nil, error)
                return
            }

            guard let checkInList = self.configStore.checkInList else {
                completionHandler(redemptionResponse, error)
                return
            }

            guard var position = redemptionResponse.position else {
                completionHandler(redemptionResponse, error)
                return
            }

            guard let dataStore = self.configStore.dataStore else {
                EventLogger.log(event: "Could not retrieve datastore!", category: .configuration, level: .fatal, type: .error)
                completionHandler(redemptionResponse, error)
                return
            }

            if let event = self.configStore.event {
                position = position.adding(order: dataStore.getOrder(by: position.orderCode, in: event))
                position = position.adding(item: dataStore.getItem(by: position.itemIdentifier, in: event))

                let checkIns = dataStore.getCheckIns(for: position, in: self.configStore.checkInList, in: event)
                position = position.adding(checkIns: checkIns)

                redemptionResponse.position = position
            }

            redemptionResponse.lastCheckIn = redemptionResponse.position?.checkins.filter {
                $0.listID == checkInList.identifier
            }.first

            completionHandler(redemptionResponse, error)
        }
    }

    public func getCheckInListStatus(completionHandler: @escaping (CheckInListStatus?, Error?) -> Void) {
        configStore.apiClient?.getCheckInListStatus(completionHandler: completionHandler)
    }
}
