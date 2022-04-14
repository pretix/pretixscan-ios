//
//  TicketJsonLogicChecker.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 09/04/2022.
//  Copyright © 2022 rami.io. All rights reserved.
//

import Foundation
import jsonlogic
import JSON

final class TicketJsonLogicChecker {
    private var checkInList: CheckInList
    
    init(list: CheckInList) {
        self.checkInList = list
    }
    
    func redeem(ticket: SignedTicketData) -> Result<Void, ValidationError> {
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
    
    private func getCustomRules() -> [String: (JSON?) -> JSON] {
        ["inList": { (json: JSON?) -> JSON in
            // receives an array of JSON values and checks if the element at index 0 is contained in the array at index 1
            guard let json = json else {
                return JSON(false)
            }
            switch json {
            case let .Array(array):
                if array.count >= 2 {
                    let element = array[0]
                    let arr = array[1]
                    switch arr {
                    case let .Array(list):
                        return JSON(list.contains(element))
                    default:
                        return JSON(false)
                    }
                }
                return JSON(false)
            default:
                return JSON(false)
            }
        },
         "objectList": { (json: JSON?) -> JSON in
            guard let json = json else {
                // empty list
                return JSON([JSON]())
            }
            switch json {
            case let .Array(array):
                return JSON(array)
            default:
                return JSON([JSON]())
            }
        },
         "lookup": { (json: JSON?) -> JSON in
            // receives an array of JSON values and returns the element at index 1 as an Int64
            guard let json = json else {
                // the value is null
                return JSON.Null
            }
            switch json {
            case let .Array(elements):
                if elements.count >= 2 {
                    switch elements[1] {
                    case let .Int(number):
                        return JSON(number)
                    case let .Double(double):
                        return JSON(Int64(double))
                    case let .String(string):
                        return JSON(Int64(string) ?? 0)
                    default:
                        return JSON.Null
                    }
                }
                return JSON.Null
            default:
                return JSON.Null
            }
        }]
    }
    
    
    enum ValidationError: Error, Hashable, Equatable {
        case rules
        case parsingError
    }
}
