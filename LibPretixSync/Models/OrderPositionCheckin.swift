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
    
    static var searchQuery = """
    SELECT secret, json_extract(json_each.value, '$.type') as checkin_type, json_extract(json_each.value, '$.datetime') as datetime, json_extract(json_each.value, '$.list') as list
    FROM (
        SELECT json_extract(json_each.value, '$.checkins') checkins, json_extract(json_each.value, '$.secret') secret
            FROM (
                SELECT json_extract(json, '$.positions') as positions FROM orders
            ), json_each(positions)
    ), json_each(checkins)
    WHERE
        json_array_length(checkins) > 0
        AND secret = ?
        AND checkin_type = ?;
    """
    
    static func from(result: FMResultSet, in database: FMDatabase) -> OrderPositionCheckin? {
        guard let secret = result.string(forColumn: "secret"),
              let type = result.string(forColumn: "checkin_type"),
              let date = result.date(forColumn: "datetime"),
              let list = result.nullableInt(forColumn: "list") else {
            return nil
        }
        return .init(secret: secret, checkInType: type, date: date, checkInListIdentifier: list)
    }
}

extension OrderPositionCheckin {
    init(from: QueuedRedemptionRequest) {
        self = .init(secret: from.secret, checkInType: from.redemptionRequest.type, date: from.redemptionRequest.date!, checkInListIdentifier: from.checkInListIdentifier)
    }
}
