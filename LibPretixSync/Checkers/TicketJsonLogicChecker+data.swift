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
        
        let queuedCheckIns =
        ((try? dataStore?.getQueuedCheckIns(ticket.secret, eventSlug: ticket.eventSlug).get()) ?? [])
            .filter({$0.redemptionRequest.date != nil && $0.redemptionRequest.type == "entry"})
            .map({OrderPositionCheckin(from: $0)})
        let orderCheckIns = (try? dataStore?.getOrderCheckIns(ticket.secret, type: "entry", self.event).get()) ?? []
        
        logger.debug("raw queuedCheckIns: \(queuedCheckIns.count), raw orderedCheckIns: \(orderCheckIns.count)")
        let entryCheckIns = queuedCheckIns + orderCheckIns
        
        return JSON([
            "now": dateFormatter.string(from: self.now),
            "now_isoweekday": calendar.dateComponents([.weekday], from: self.now).weekday! - 1, // Weekday starts with 1 on Sunday but server expects Monday = 1 https://developer.apple.com/documentation/foundation/calendar/component/weekday
            "minutes_since_last_entry": Self.getMinutesSinceLastEntryForCheckInListOrMinus1(entryCheckIns, listId: self.checkInList.identifier, now: self.now),
            "minutes_since_first_entry": Self.getMinutesSinceFirstEntryForCheckInListOrMinus1(entryCheckIns, listId: self.checkInList.identifier, now: self.now),
            "product": ticket.item,
            "variation": (ticket.variation ?? 0) > 0 ? "\(ticket.variation!)" : "",
            "entries_number": entryCheckIns.count,
            "entries_today": Self.getEntriesTodayCount(entryCheckIns, calendar: calendar, today: self.now),
            "entries_days": Self.getEntriesDaysCount(entryCheckIns, calendar: calendar)
        ]).rawString()
    }
    
    static func getMinutesSinceFirstEntryForCheckInListOrMinus1(_ entryCheckIns: [OrderPositionCheckin], listId: Identifier, now: Date) -> Int {
        if let lastCheckInDate = entryCheckIns
            .filter({
                $0.checkInListIdentifier == listId
            })
                .sorted(by: {(a, b) in a.date < b.date})
                .first?.date {
            
            return Int((now - lastCheckInDate) / 60)
        }
        
        return -1
    }
    
    static func getMinutesSinceLastEntryForCheckInListOrMinus1(_ entryCheckIns: [OrderPositionCheckin], listId: Identifier, now: Date) -> Int {
        if let lastCheckInDate = entryCheckIns
            .filter({
                $0.checkInListIdentifier == listId
            })
                .sorted(by: {(a, b) in a.date < b.date})
                .last?.date {
            
            return Int((now - lastCheckInDate) / 60)
        }
        
        return -1
    }
    
    static func getEntriesTodayCount(_ entryCheckIns: [OrderPositionCheckin], calendar: Calendar, today: Date) -> Int {
        entryCheckIns
            .filter({
                calendar.isDate($0.date, inSameDayAs: today)
            })
            .count
    }
    
    static func getEntriesDaysCount(_ entryCheckIns: [OrderPositionCheckin], calendar: Calendar) -> Int {
        (
            Set(
                entryCheckIns
                    .map({
                        calendar.dateComponents([.year, .month, .day], from: $0.date)
                    })
            )
        )
        .count
    }
}
