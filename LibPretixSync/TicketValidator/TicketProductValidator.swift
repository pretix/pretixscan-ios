//
//  DatalessTicketValidator.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 28/10/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation

final class TicketProductValidator {
    private var checkInList: CheckInList
    
    init(list: CheckInList) {
        self.checkInList = list
    }
    
    
    func redeem(ticket: SignedTicketData) -> Result<SignedTicketData, ValidationError> {
        // is the product part of the check-in list
        if !checkInList.allProducts {
            if let limitProducts = checkInList.limitProducts, limitProducts.contains(ticket.item) {
                return .failure(.product)
            }
        }
        
        // is the subevent part of the check-in list
        if let subEventId = checkInList.subEvent, subEventId != ticket.subEvent {
            return .failure(.invalidProductSubEvent)
        }
        
        return .success(ticket)
    }
    
    enum ValidationError: Error, Hashable, Equatable, CaseIterable {
        /// The product of the ticket is not part of the check-in list
        case product
        /// The subevent of the ticket is not part of the check-in list
        case invalidProductSubEvent
    }
}
