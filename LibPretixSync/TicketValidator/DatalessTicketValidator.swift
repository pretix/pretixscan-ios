//
//  DatalessTicketValidator.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 28/10/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation


final class DatalessTicketValidator {
    weak var dataStore: SignedDataStore?
    
    init(dataStore: SignedDataStore) {
        self.dataStore = dataStore
    }
    
    
    func redeem(_ checkInList: CheckInList, _ event: Event, _ secret: String, answers: [Answer]?,
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
                    return .success(CheckStatus.valid(variation: variation))
                }
                
                switch TicketEntryAnswersChecker(item: item, dataStore: dataStore).redeem(ticket: signedTicket, event: event, answers: answers) {
                case .success:
                    switch TicketMultiEntryChecker(list: checkInList, dataStore: dataStore).redeem(secret: secret, event: event) {
                    case .success():
                        return .success(CheckStatus.valid(variation: variation))
                    case .failure(let check):
                        switch check {
                        case .alreadyRedeemed:
                            return .success(CheckStatus.alreadyRedeemed)
                        case .unknownError:
                            return .failure(APIError.notFound)
                        }
                    }
                case .failure(let check):
                    switch check {
                    case .incomplete(questions: let questions):
                        return .success(CheckStatus.incomplete(questions: questions, answers: answers))
                    case .unknownError:
                        return .failure(APIError.notFound)
                    }
                }
            case .failure(let productReason):
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
            switch signatureReason {
            case .noKeys:
                return .success(CheckStatus.invalid)
            case .invalid:
                return .success(CheckStatus.invalid)
            case .revoked:
                return .success(CheckStatus.revoked)
            }
        }
    }
    
    enum CheckStatus: Equatable {
        case valid(variation: ItemVariation?)
        case invalid
        case alreadyRedeemed
        case revoked
        case product
        case incomplete(questions: [Question], answers: [Answer]?)
    }
}
