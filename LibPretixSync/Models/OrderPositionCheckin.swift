//
//  OrderPositionCheckin.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 15/06/2022.
//  Copyright © 2022 rami.io. All rights reserved.
//

import Foundation
import FMDB

public struct OrderPositionCheckin: Codable, Hashable {
    public let secret: String
    public let checkInType: String
    public let date: Date
    public let checkInListIdentifier: Identifier
}

extension OrderPositionCheckin {
    init(from: QueuedRedemptionRequest) {
        self = .init(secret: from.secret, checkInType: from.redemptionRequest.type, date: from.redemptionRequest.date!, checkInListIdentifier: from.checkInListIdentifier)
    }
}

extension Order {
    /// Returns a list of all check-ins in the given order, for all positions and all lists
    private var previousCheckIns: [OrderPositionCheckin] {
        return self.positions?.flatMap({position in position.checkins.map({checkin in OrderPositionCheckin(secret: position.secret, checkInType: checkin.type, date: checkin.date, checkInListIdentifier: checkin.listID)})}) ?? []
    }
    
    /// Return a list of checkins for the given `secret` in the given `list`
    func getPreviousCheckIns(secret: String, listId: Identifier) -> [OrderPositionCheckin] {
        return previousCheckIns.filter({$0.secret == secret && $0.checkInListIdentifier == listId})
    }
}
