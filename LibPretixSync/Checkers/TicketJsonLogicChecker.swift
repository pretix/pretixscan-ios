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
    weak var dataStore: DatalessDataStore?
    
    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()
    
    init(list: CheckInList, dataStore: DatalessDataStore? = nil) {
        self.checkInList = list
        self.dataStore = dataStore
    }
    
    func redeem(ticket: TicketData) -> Result<Void, ValidationError> {
        guard let rules = self.checkInList.rules, let rulesJSON = rules.rawString() else {
            // no rules to evaluate, check passes
            return .success(())
        }
        
        do {
            
            let result: Bool = try JsonLogic(rulesJSON, customOperators: getCustomRules()).applyRule(to: getTicketData(ticket))
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
    
    struct TicketData {
        let secret: String
        let eventSlug: String
        let item: Identifier
        let variation: Identifier?
        let subEvent: Identifier
    }
}
