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
    public var isOnline: Bool {
        return true
    }
    
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
        guard let questions = configStore.dataStore?.getQuestions(for: item, in: event) else {
            completionHandler(nil, APIError.notFound)
            return
        }

        switch questions {
        case .failure(let error):
            completionHandler(nil, error)
        case .success(let resultQuestions):
            completionHandler(resultQuestions, nil)
        }
    }
    
    /// Searches for all order positions within the currently selected Event and CheckIn List
    public func search(query: String, _ locale: Locale = Locale.current) async throws -> [SearchResult] {
        let orderPositions = try await searchOrderPositions(query: query)
        let event = self.configStore.event
        guard let event = event else {
            throw APIError.notConfigured(message: "No Event is set")
        }
        
        return orderPositions.map({ op in
            let item = self.configStore.dataStore?.getItem(by: op.itemIdentifier, in: event)
            var sr = SearchResult()
            sr.ticket = item?.name.representation(in: locale)
            if let variationId = op.variation {
                sr.variation = item?.variations.first(where: {$0.identifier == variationId})?.name.representation(in: locale)
            }
            sr.attendeeName = op.attendeeName
            sr.seat = op.seat?.name
            sr.orderCode = op.orderCode
            sr.positionId = op.positionid
            sr.secret = op.secret
            sr.isRedeemed = op.checkins.count > 0
            let orderStatus = op.orderStatus ?? op.order?.status
            if orderStatus == .paid || (orderStatus == .pending && op.order?.validIfPending == true) {
                sr.status = .paid
            } else if orderStatus == .pending {
                sr.status = .pending
            } else {
                sr.status = .cancelled
            }
            sr.isRequireAttention = op.requiresAttention ?? false
            return sr
        })
    }
    
    /// Searches for all order positions within the currently selected Event and CheckIn List
    func searchOrderPositions(query: String) async throws -> [OrderPosition] {
        try await withCheckedThrowingContinuation { continuation in
            configStore.apiClient?.getSearchResults(query: query) { orderPositions, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    if let results = orderPositions {
                        continuation.resume(returning: results)
                    } else {
                        continuation.resume(throwing: APIError.emptyResponse)
                    }
                }
            }
        }
    }

    /// Check in an attendee, identified by OrderPosition, into the currently configured CheckInList
    ///
    /// - See `RedemptionResponse` for the response returned in the completion handler.
    public func redeem(secret: String, force: Bool, ignoreUnpaid: Bool, answers: [Answer]? = nil,
                       as type: String,
                       completionHandler: @escaping (RedemptionResponse?, Error?) -> Void) {
        configStore.apiClient?.redeem(secret: secret, force: force, ignoreUnpaid: ignoreUnpaid,
                                      answers: answers, as: type) { redemptionResponse, error in
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

            if redemptionResponse == .redeemed {
                PXTemporaryFile.cleanUp(answers?.compactMap({$0.fileUrl}) ?? [])
            }
            
            completionHandler(redemptionResponse, error)
        }
    }

    public func getCheckInListStatus(completionHandler: @escaping (CheckInListStatus?, Error?) -> Void) {
        configStore.apiClient?.getCheckInListStatus(completionHandler: completionHandler)
    }
}
