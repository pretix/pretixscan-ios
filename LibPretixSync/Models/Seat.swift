//
//  Seat.swift
//  Seat
//
//  Created by Konstantin Kostov on 10/09/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation

public struct Seat: Codable, Identifiable, Hashable {
    /// Internal ID of the seat instance
    public let id: Int
    /// Human-readable seat name
    public let name: String?
    /// Identifier of the seat within the seating plan
    public let seatingPlanid: String?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case seatingPlanid = "seat_guid"
    }
}

extension Seat {
    init?(_ seat_id: Int?, _ seat_name: String?, _ seat_guid: String?) {
        guard let id = seat_id else {
            return nil
        }
        self = Seat(id: id, name: seat_name, seatingPlanid: seat_guid)
    }
}
