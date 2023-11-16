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
    public var isOnline: Bool {
        return false
    }
    
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
    
    /// Searches for all order positions within the currently selected Event and CheckIn List
    public func search(query: String, _ locale: Locale = Locale.current) async throws -> [SearchResult] {
        let event = self.configStore.event
        let checkInList = self.configStore.checkInList
        guard let event = event, let checkInList = checkInList else {
            throw APIError.notConfigured(message: "No Event is set")
        }
        
        let orderPositions = try await searchOrderPositions(query: query, event: event, checkInList: checkInList)
        
        return orderPositions.map({ op in
            var sr = SearchResult()
            sr.ticket = op.item?.name.representation(in: locale)
            if let variationId = op.variation {
                sr.variation = op.item?.variations.first(where: {$0.identifier == variationId})?.name.representation(in: locale)
            }
            sr.attendeeName = op.attendeeName
            sr.seat = op.seat?.name
            sr.orderCode = op.orderCode
            sr.positionId = op.positionid
            sr.secret = op.secret
            
            let checkins = getQueuedAndKnownCheckIns(secret: op.secret, event: event, order: op.order, listId: checkInList.identifier)
            sr.isRedeemed = !checkins.isEmpty
            let orderStatus = op.orderStatus ?? op.order?.status
            if orderStatus == .paid || (orderStatus == .pending && op.order?.validIfPending == true) {
                sr.status = .paid
            } else if orderStatus == .pending {
                sr.status = .pending
            } else {
                sr.status = .cancelled
            }
            sr.isRequireAttention = op.order?.checkInAttention ?? false
            return sr
        })
    }
    
    /// Searches for all order positions within the currently selected Event and CheckIn List
    func searchOrderPositions(query: String, event: Event, checkInList: CheckInList) async throws -> [OrderPosition] {
        try await withCheckedThrowingContinuation { continuation in
            configStore.dataStore?.searchOrderPositions(query, in: event, checkInList: checkInList, completionHandler: { orderPositions, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    if let results = orderPositions {
                        continuation.resume(returning: results)
                    } else {
                        continuation.resume(throwing: APIError.emptyResponse)
                    }
                }
            })
        }
    }
    
    func getQueuedAndKnownCheckIns(secret: String, event: Event, order: Order?, listId: Identifier) -> [OrderPositionCheckin] {
        let queuedCheckIns =
        ((try? configStore.dataStore?.getQueuedCheckIns(secret, eventSlug: event.slug, listId: listId).get()) ?? []).map({OrderPositionCheckin(from: $0)})
        let orderCheckIns = order?.getPreviousCheckIns(secret: secret, listId: listId) ?? []
        
        logger.debug("queued: \(queuedCheckIns.count), order: \(orderCheckIns.count)")
        return queuedCheckIns + orderCheckIns
    }
    
    public func redeem(configuration: TicketStatusConfiguration, as type: String) async throws -> RedemptionResponse? {
        return try await withCheckedThrowingContinuation { continuation in
            redeem(secret: configuration.secret, force: configuration.force, ignoreUnpaid: configuration.ignoreUnpaid, answers: configuration.answers, as: type) {redemptionResponse, error in
                
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: redemptionResponse)
                }
            }
        }
    }
    
    
    /// Check in an attendee, identified by OrderPosition, into the currently configured CheckInList
    ///
    /// - See `RedemptionResponse` for the response returned in the completion handler.
    public func redeem(secret: String, force: Bool, ignoreUnpaid: Bool, answers: [Answer]?,
                       as type: String,
                       completionHandler: @escaping (RedemptionResponse?, Error?) -> Void) {
        
        guard let event = configStore.event else {
            completionHandler(nil, APIError.notConfigured(message: "No Event is set"))
            return
        }
        
        guard let checkInList = configStore.checkInList else {
            completionHandler(nil, APIError.notConfigured(message: "No CheckInList is set"))
            return
        }
        
        
        redeem(checkInList, event, secret, force: force, ignoreUnpaid: ignoreUnpaid, answers: answers, as: type, completionHandler: {[weak self] (response, error) in
            
            if let failedCheckIn = FailedCheckIn(response: response, error: error, event.slug, checkInList.identifier, type, secret, event) {
                logger.debug("Recording FailedCheckIn for upload, reason: \(failedCheckIn.errorReason)")
                self?.configStore.dataStore?.store([failedCheckIn], for: event)
            }
            
            completionHandler(response, error)
        })
    }
    
    func redeem(_ checkInList: CheckInList, _ event: Event, _ secret: String, force: Bool, ignoreUnpaid: Bool, answers: [Answer]?,
                as type: String,
                completionHandler: @escaping (RedemptionResponse?, Error?) -> Void) {
        
        // Redeem using DataStore
        // A QueuedRedemptionRequest will automatically be generated
        let response = configStore.dataStore?.redeem(secret: secret, force: force, ignoreUnpaid: ignoreUnpaid, answers: answers,
                                                     in: event, as: type, in: checkInList)
        
        guard let dataStore = configStore.dataStore else {
            completionHandler(nil, APIError.notConfigured(message: "Redeeming without a nil datastore"))
            return
        }
        
        guard var response = response else {
            // the order was not found in local storage, attempt dataless flow
            DatalessTicketValidator(dataStore: dataStore).redeem(checkInList, event, secret, ignoreUnpaid: ignoreUnpaid, answers: answers, as: type, completionHandler: completionHandler)
            return
        }
        
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
                .adding(item: dataStore.getItem(by: position.itemIdentifier, in: event))
                .adding(checkIns: dataStore.getCheckIns(for: position, in: self.configStore.checkInList, in: event))
                .adding(answers: response.answers)
            response.position = position
            
            response.lastCheckIn = position.checkins.filter {
                $0.listID == checkInList.identifier
            }.first
        }
        
        
        completionHandler(response, nil)
        configStore.syncManager.beginSyncingIfAutoSync()
    }
}
