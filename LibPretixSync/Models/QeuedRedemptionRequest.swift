//
//  QeuedRedemptionRequest.swift
//  PretixScan
//
//  Created by Daniel Jilg on 01.05.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

/// Encapsulates a Redemption Request that should be queued until it has been uploaded to the server.
///
/// - See also `RedemptionRequest`
public struct QueuedRedemptionRequest: Model {
    public static var humanReadableName = "Queued Redemption Request"
    public static var stringName = "queued_redemption_requests"

    public let redemptionRequest: RedemptionRequest
    public let event: Event
    public let checkInList: CheckInList
    public let secret: String
}

extension QueuedRedemptionRequest: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(redemptionRequest)
        hasher.combine(event)
        hasher.combine(checkInList)
        hasher.combine(secret)
    }
}
