// Created by konstantin on 16/02/2023.
// Copyright (c) 2023. All rights reserved.

import Foundation

final class TicketEntryValidFromToChecker {
    private var now: Date
    
    init(now: Date) {
        self.now = now
    }
    
    func redeem(position: OrderPosition) -> Result<Void, ValidationError> {
        if let from = position.validFrom, now < from {
            return .failure(.invalidTime)
        }
        
        if let until = position.validUntil, now > until {
            return .failure(.invalidTime)
        }
        
        return .success(())
    }
    
    enum ValidationError: Error, Hashable, Equatable {
        case invalidTime
    }
}
