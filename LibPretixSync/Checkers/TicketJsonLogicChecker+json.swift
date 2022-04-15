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
        
        // FIXME: - Events may be in a different timezone, Event.timezone
        let calendar = Calendar.current
        
        return JSON([
            "now": dateFormatter.string(from: Date()),
            "product": ticket.item,
            "variation": (ticket.variation ?? 0) > 0 ? "\(ticket.variation!)" : "",
            "entries_number": checkIns.filter({$0.redemptionRequest.type == "entry"}).count,
            "entries_today": checkIns.filter({$0.redemptionRequest.date != nil && calendar.isDateInToday($0.redemptionRequest.date!) && $0.redemptionRequest.type == "entry"}).count,
            "entries_days": (Set(checkIns.filter({$0.redemptionRequest.date != nil}).map({calendar.component(.day, from: $0.redemptionRequest.date!)}))).count
        ]).rawString()
    }
}
