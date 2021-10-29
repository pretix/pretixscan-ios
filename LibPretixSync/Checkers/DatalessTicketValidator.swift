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
                as type: String) -> Result<RedemptionResponse, Error> {
        guard let dataStore = dataStore else {
            assertionFailure("DatalessTicketValidator missing dataStore")
            return .failure(APIError.notConfigured(message: "Ticket validator without a datastore"))
        }

        
        switch TicketSignatureChecker(dataStore: dataStore).redeem(secret: secret, event: event) {
        case .success(let signedTicket):
            switch TicketProductChecker(list: checkInList, dataStore: dataStore).redeem(ticket: signedTicket, event: event) {
            case .success(let item):
                if type == "exit" {
                    return .success(RedemptionResponse.redeemed)
                }
                switch TicketEntryAnswersChecker(item: item, dataStore: dataStore).redeem(ticket: signedTicket, event: event, answers: answers) {
                case .success:
                    let variation = TicketVariationChecker(list: checkInList, dataStore: dataStore).redeem(ticket: signedTicket, item: item)
                    fatalError("Not implemented yet")
                case .failure(let check):
                    switch check {
                    case .incomplete(questions: let questions):
                        return .success(RedemptionResponse(incompleteQuestions: questions, answers))
                    case .unknownError:
                        return .failure(APIError.notFound)
                    }
                }
            case .failure(let reason):
                return .success(RedemptionResponse(validationError: reason))
            }
        case .failure(let reason):
            return .success(RedemptionResponse(validationError: reason))
        }
    }
}
