//
//  DatalessTicketValidator.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 28/10/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation


/// The validator implements the dataless check client flow https://docs.pretix.eu/en/latest/development/algorithms/checkin.html#client-side
final class DatalessTicketValidator {
    weak var dataStore: DatalessDataStore?
    
    init(dataStore: DatalessDataStore) {
        self.dataStore = dataStore
    }
    
    
    func redeem(_ checkInList: CheckInList, _ event: Event, _ secret: String, ignoreUnpaid: Bool, answers: [Answer]?,
                as type: String,
                completionHandler: @escaping (RedemptionResponse?, Error?) -> Void) {
        logger.debug("Attempting to redeem without data")
        switch redeem(checkInList, event, secret, answers: answers, as: type) {
        case .success(let checkStatus):
            var response: RedemptionResponse
            switch checkStatus {
            case .valid(let item, _):
                let request = RedemptionRequest(date: Date(), force: true, ignoreUnpaid: ignoreUnpaid, nonce: NonceGenerator.nonce(), answers: answers, type: type)
                let queuedRequest = QueuedRedemptionRequest(redemptionRequest: request, eventSlug: event.slug, checkInListIdentifier: checkInList.identifier, secret: secret)
                dataStore?.store(queuedRequest, for: event)
                response = RedemptionResponse.redeemed(item)
            case .invalid:
                response = RedemptionResponse.invalid
                if let failedCheckIn = FailedCheckIn(response: response, error: nil, event.slug, checkInList.identifier, type, secret, event) {
                    dataStore?.store(failedCheckIn, for: event)
                }
            case .alreadyRedeemed:
                response = RedemptionResponse.alreadyRedeemed
                if let failedCheckIn = FailedCheckIn(response: response, error: nil, event.slug, checkInList.identifier, type, secret, event) {
                    dataStore?.store(failedCheckIn, for: event)
                }
            case .revoked:
                response = RedemptionResponse.revoked
                if let failedCheckIn = FailedCheckIn(response: response, error: nil, event.slug, checkInList.identifier, type, secret, event) {
                    dataStore?.store(failedCheckIn, for: event)
                }
            case .product:
                response = RedemptionResponse.product
                if let failedCheckIn = FailedCheckIn(response: response, error: nil, event.slug, checkInList.identifier, type, secret, event) {
                    dataStore?.store(failedCheckIn, for: event)
                }
            case .incomplete(questions: let questions, answers: let answers):
                response = RedemptionResponse(incompleteQuestions: questions, answers)
                if let failedCheckIn = FailedCheckIn(response: response, error: nil, event.slug, checkInList.identifier, type, secret, event) {
                    dataStore?.store(failedCheckIn, for: event)
                }
            case .rules:
                response = RedemptionResponse.rules
                if let failedCheckIn = FailedCheckIn(response: response, error: nil, event.slug, checkInList.identifier, type, secret, event) {
                    dataStore?.store(failedCheckIn, for: event)
                }
            case .blocked:
                response = RedemptionResponse.blocked
                if let failedCheckIn = FailedCheckIn(response: response, error: nil, event.slug, checkInList.identifier, type, secret, event) {
                    dataStore?.store(failedCheckIn, for: event)
                }
            }
            completionHandler(response, nil)
        case .failure(let error):
            completionHandler(nil, error)
        }
    }
    
    private func redeem(_ checkInList: CheckInList, _ event: Event, _ secret: String, answers: [Answer]?,
                        as type: String) -> Result<CheckStatus, Error> {
        
        
        guard let dataStore = dataStore else {
            assertionFailure("DatalessTicketValidator missing dataStore")
            return .failure(APIError.notConfigured(message: "Ticket validator without a datastore"))
        }
        
        
        switch TicketSignatureChecker(dataStore: dataStore).redeem(secret: secret, event: event) {
        case .success(let signedTicket):
            switch TicketProductChecker(list: checkInList, dataStore: dataStore).redeem(ticket: signedTicket, event: event) {
            case .success(let item):
                let variation = TicketVariationChecker(list: checkInList, dataStore: dataStore).redeem(ticket: signedTicket, item: item)
                if type == "exit" {
                    return .success(CheckStatus.valid(item: item, variation: variation))
                }
                
                let subEvent = ((try? dataStore.getSubEvents(for: event).get()) ?? []).first
                switch TicketJsonLogicChecker(list: checkInList, dataStore: dataStore, event: event, subEvent: subEvent, date: Date()).redeem(ticket: .init(secret: secret, eventSlug: event.slug, item: signedTicket.item, variation: signedTicket.variation)) {
                case .success():
                    switch TicketEntryAnswersChecker(item: item, dataStore: dataStore).redeem(event: event, answers: answers) {
                    case .success:
                        switch TicketMultiEntryChecker(list: checkInList, dataStore: dataStore).redeem(secret: secret, event: event) {
                        case .success():
                            return .success(CheckStatus.valid(item: item, variation: variation))
                        case .failure(let check):
                            logger.debug("TicketMultiEntryChecker failed: \(String(describing: check))")
                            switch check {
                            case .alreadyRedeemed:
                                return .success(CheckStatus.alreadyRedeemed)
                            case .unknownError:
                                return .failure(APIError.notFound)
                            }
                        }
                    case .failure(let check):
                        logger.debug("TicketEntryAnswersChecker failed: \(String(describing: check))")
                        switch check {
                        case .incomplete(questions: let questions):
                            return .success(CheckStatus.incomplete(questions: questions, answers: answers))
                        case .unknownError:
                            return .failure(APIError.notFound)
                        }
                    }
                case .failure(let rulesError):
                    logger.debug("TicketJsonLogicChecker failed: \(String(describing: rulesError))")
                    return .success(CheckStatus.rules)
                }
            case .failure(let productReason):
                logger.debug("TicketProductChecker failed: \(String(describing: productReason))")
                switch productReason {
                case .product(_):
                    return .success(CheckStatus.product)
                case .invalidProductSubEvent:
                    return .success(CheckStatus.invalid)
                case .unknownItem(_):
                    return .success(CheckStatus.product)
                }
            }
        case .failure(let signatureReason):
            logger.debug("TicketSignatureChecker failed: \(String(describing: signatureReason))")
            switch signatureReason {
            case .noKeys:
                return .success(CheckStatus.invalid)
            case .invalid:
                return .success(CheckStatus.invalid)
            case .revoked:
                return .success(CheckStatus.revoked)
            case .blocked:
                return .success(CheckStatus.blocked)
            }
        }
    }
    
    enum CheckStatus: Equatable {
        case valid(item: Item, variation: ItemVariation?)
        case invalid
        case alreadyRedeemed
        case revoked
        case blocked
        case product
        case incomplete(questions: [Question], answers: [Answer]?)
        case rules
    }
}
