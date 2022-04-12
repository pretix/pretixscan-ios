//
//  TicketJsonLogicChecker.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 09/04/2022.
//  Copyright © 2022 rami.io. All rights reserved.
//

import Foundation
import jsonlogic

final class TicketJsonLogicChecker {
    private var checkInList: CheckInList
    
    init(list: CheckInList) {
        self.checkInList = list
    }
    
    func redeem() -> Result<Void, ValidationError> {
        guard let rules = self.checkInList.rules, let rulesJSON = rules.rawString() else {
            // no rules to evaluate, check passes
            return .success(())
        }
        
        do {
            let result: Bool = try applyRule(rulesJSON)
            return result ? .success(()) : .failure(.rules)
        } catch {
            logger.error("Rule parsing error \(String(describing: error))")
            return .failure(.parsingError)
        }
    }
    
    
    enum ValidationError: Error, Hashable, Equatable {
        case rules
        case parsingError
    }
}
