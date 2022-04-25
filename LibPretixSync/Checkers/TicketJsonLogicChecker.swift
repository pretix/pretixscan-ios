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
    var checkInList: CheckInList
    weak var dataStore: DatalessDataStore?
    
    /// The date formatter used to serialize and deserialize datetimestamps in JSON
    let dateFormatter: DateFormatter
    
    /// The date formatter used to serialize and deserialize timestamps in JSON
    let timeFormatter: DateFormatter
    
    /// The date the checker uses as a reference to "now" when validating ticket rules
    let now: Date
    
    /// The calendar used to calculate date and time components
    var calendar: Calendar
    
    
    let event: Event
    let subEvent: SubEvent?
    
    init(list: CheckInList, dataStore: DatalessDataStore? = nil, event: Event, subEvent: SubEvent? = nil, date: Date = Date()) {
        self.now = date
        self.event = event
        self.subEvent = subEvent
        self.checkInList = list
        self.dataStore = dataStore
        self.dateFormatter = Self.createDateFormatter(timeZone: event.timezone)
        self.timeFormatter = Self.createTimeFormatter(timeZone: event.timezone)
        self.calendar = Self.createCalendar(timeZone: event.timezone)
    }
    
    func redeem(ticket: TicketData) -> Result<Void, ValidationError> {
        guard let rules = self.checkInList.rules, let rulesJSON = rules.rawString() else {
            // no rules to evaluate, check passes
            return .success(())
        }
        
        do {
            
            let data = getTicketData(ticket)
            let result: Bool = try JsonLogic(rulesJSON, customOperators: getCustomRules()).applyRule(to: data)
            switch result {
            case true:
                return .success(())
            case false:
                logger.debug("🚧 Rules validation error.\ndata:\(data ?? "nil")\nrules: \(rulesJSON) \n")
                return .failure(.rules)
            }
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
    
    static let DateFormat: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    static let TimeFormat: String = "HH:mm"
    
    private static func createTimeFormatter(timeZone: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = TicketJsonLogicChecker.TimeFormat
        formatter.timeZone = TimeZone(identifier: timeZone)!
        return formatter
    }
    
    private static func createDateFormatter(timeZone: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = TicketJsonLogicChecker.DateFormat
        formatter.timeZone = TimeZone(identifier: timeZone)!
        return formatter
    }
    
    private static func createCalendar(timeZone: String) -> Calendar {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: timeZone)!
        return calendar
    }
}
