//
//  TicketJsonLogicChecker+json.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 14/04/2022.
//  Copyright © 2022 rami.io. All rights reserved.
//

import Foundation
import SwiftyJSON

extension TicketJsonLogicChecker {
    func getTicketData(_ ticket: TicketData) -> String? {
        let checkIns = (try? dataStore?.getQueuedCheckIns(ticket.secret, eventSlug: ticket.eventSlug).get()) ?? []
        
        return JSON([
            "now": dateFormatter.string(from: self.now),
            "now_isoweekday": calendar.dateComponents([.weekday], from: self.now).weekday! - 1, // Weekday starts with 1 on Sunday but server expects Monday = 1 https://developer.apple.com/documentation/foundation/calendar/component/weekday
            "minutes_since_last_entry": Self.getMinutesSinceLastEntryForCheckInListOrMinus1(checkIns, listId: self.checkInList.identifier, now: self.now),
            "minutes_since_first_entry": Self.getMinutesSinceLastEntryForCheckInListOrMinus1(checkIns, listId: self.checkInList.identifier, now: self.now),
            "product": ticket.item,
            "variation": (ticket.variation ?? 0) > 0 ? "\(ticket.variation!)" : "",
            "entries_number": checkIns.filter({$0.redemptionRequest.type == "entry"}).count,
            "entries_today": Self.getEntriesTodayCount(checkIns, calendar: calendar, today: self.now),
            "entries_days": Self.getEntriesDaysCount(checkIns, calendar: calendar)
        ]).rawString()
    }
    
    static func getMinutesSinceFirstEntryForCheckInListOrMinus1(_ checkIns: [QueuedRedemptionRequest], listId: Identifier, now: Date) -> Int {
        if let lastCheckInDate = checkIns
            .filter({
                $0.redemptionRequest.date != nil &&
                $0.checkInListIdentifier == listId &&
                $0.redemptionRequest.type == "entry"
            })
            .sorted(by: {(a, b) in a.redemptionRequest.date! < b.redemptionRequest.date!})
            .first?.redemptionRequest.date {
            
            return Int((now - lastCheckInDate) / 60)
        }
        
        return -1
    }
    
    static func getMinutesSinceLastEntryForCheckInListOrMinus1(_ checkIns: [QueuedRedemptionRequest], listId: Identifier, now: Date) -> Int {
        if let lastCheckInDate = checkIns
            .filter({
                $0.redemptionRequest.date != nil &&
                $0.checkInListIdentifier == listId &&
                $0.redemptionRequest.type == "entry"
            })
            .sorted(by: {(a, b) in a.redemptionRequest.date! < b.redemptionRequest.date!})
            .last?.redemptionRequest.date {
            
            return Int((now - lastCheckInDate) / 60)
        }
        
        return -1
    }
    
    static func getEntriesTodayCount(_ checkIns: [QueuedRedemptionRequest], calendar: Calendar, today: Date) -> Int {
        checkIns
            .filter({
                $0.redemptionRequest.date != nil &&
                calendar.isDate($0.redemptionRequest.date!, inSameDayAs: today) &&
                $0.redemptionRequest.type == "entry"
            })
            .count
    }
    
    static func getEntriesDaysCount(_ checkIns: [QueuedRedemptionRequest], calendar: Calendar) -> Int {
        (
            Set(
                checkIns
                    .filter({$0.redemptionRequest.date != nil})
                    .map({
                        calendar.dateComponents([.year, .month, .day], from: $0.redemptionRequest.date!)
                    })
            )
        )
        .count
    }
}
