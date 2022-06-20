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
    var previousCheckIns: [OrderPositionCheckin] {
        return self.positions?.flatMap({position in position.checkins.map({checkin in OrderPositionCheckin(secret: position.secret, checkInType: checkin.type, date: checkin.date, checkInListIdentifier: checkin.listID)})}) ?? []
    }
}
