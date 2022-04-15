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
        guard let checkIns = try? dataStore?.getQueuedCheckIns(ticket.secret, eventSlug: ticket.eventSlug).get() else {
            fatalError("dataStore instance has been disposed")
        }
        
        let calendar = Calendar.current
        
        return JSON([
            "product": ticket.item,
            "variation": (ticket.variation ?? 0) > 0 ? "\(ticket.variation!)" : "",
            "entries_today": checkIns.filter({$0.redemptionRequest.date != nil && calendar.isDateInToday($0.redemptionRequest.date!) && $0.redemptionRequest.type == "entry"}).count
        ]).rawString()
    }
}
