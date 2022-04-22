//
//  TicketJsonLogicChecker+rules.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 15/04/2022.
//  Copyright © 2022 rami.io. All rights reserved.
//

import Foundation
import JSON

extension TicketJsonLogicChecker {
    func getCustomRules() -> [String: (JSON?) -> JSON] {
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
        },
         "buildTime": {(json: JSON?) -> JSON in
            guard let json = json,
                  case let .Array(arguments) = json, arguments.count > 0,
                  case let .String(timeType) = arguments[0] else {
                // the value is null
                return JSON.Null
            }
            
            switch timeType {
            case "custom":
                guard arguments.count >= 2,
                      case let .String(dateString) = arguments[1],
                      let date = self.dateFormatter.date(from: dateString) else {
                    logger.warning("🚧 buildTime custom: invalid or missing date value")
                    return JSON.Null
                }
                return JSON(self.dateFormatter.string(from: date))
            case "date_admission":
                guard let value = self.getSubEventOrEventDateAdmission() else {
                    logger.warning("🚧 buildTime date_admission: event has no date_admission and no date_from")
                    return JSON.Null
                }
                return JSON(self.dateFormatter.string(from: value))
            case "date_from":
                guard let value = self.getSubEventOrEventDateFrom() else {
                    logger.warning("🚧 buildTime date_from: event has no date_from")
                    return JSON.Null
                }
                return JSON(self.dateFormatter.string(from: value))
            case "date_to":
                guard let value = self.getSubEventOrEventDateTo() else {
                    logger.warning("🚧 buildTime date_to: event has no date_to")
                    return JSON.Null
                }
                return JSON(self.dateFormatter.string(from: value))
            default:
                return JSON.Null
            }
        },
         "isAfter": {(json: JSON?) -> JSON in
            guard let json = json,
                  case let .Array(arguments) = json, arguments.count == 2 || arguments.count == 3,
                  case let .String(dateStr) = arguments[0], let date = self.dateFormatter.date(from: dateStr),
                  case let .String(rightDateStr) = arguments[1], let rightDate = self.dateFormatter.date(from: rightDateStr) else {
                return JSON.Null
            }
            
            if arguments.count == 2 || arguments[2] == JSON.Null {
                return JSON(date > rightDate)
            } else {
                guard case let .Int(minutes) = arguments[2] else {
                    return JSON.Null
                }
                return JSON(Calendar.current.date(byAdding: .minute, value: Int(minutes), to: date)! > rightDate)
            }
        },
         "isBefore": {(json: JSON?) -> JSON in
            guard let json = json,
                  case let .Array(arguments) = json, arguments.count == 2 || arguments.count == 3,
                  case let .String(dateStr) = arguments[0], let date = self.dateFormatter.date(from: dateStr),
                  case let .String(rightDateStr) = arguments[1], let rightDate = self.dateFormatter.date(from: rightDateStr) else {
                return JSON.Null
            }
            
            if arguments.count == 2 || arguments[2] == JSON.Null {
                return JSON(date < rightDate)
            } else {
                guard case let .Int(minutes) = arguments[2] else {
                    return JSON.Null
                }
                return JSON(Calendar.current.date(byAdding: .minute, value: -Int(minutes), to: date)! < rightDate)
            }
        },]
    }
    
    func getSubEventOrEventDateAdmission() -> Date? {
        if let subEvent = self.subEvent {
            return subEvent.dateAdmission ?? subEvent.dateFrom
        }
        
        return self.event.dateAdmission ?? self.event.dateFrom
    }
    
    func getSubEventOrEventDateFrom() -> Date? {
        if let subEvent = self.subEvent {
            return subEvent.dateFrom
        }
        
        return self.event.dateFrom
    }
    
    func getSubEventOrEventDateTo() -> Date? {
        if let subEvent = self.subEvent {
            return subEvent.dateTo
        }
        
        return self.event.dateTo
    }
}
