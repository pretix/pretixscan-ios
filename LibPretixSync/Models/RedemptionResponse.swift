//
//  RedemptionResponse.swift
//  PretixScan
//
//  Created by Daniel Jilg on 25.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

/// The result of a `RedemptionRequest`, reporting wether the check in was successful.
///
/// - See also `RedemptionRequest`
/// - See also `APIClient.redeem(_:completionHandler:)`
public struct RedemptionResponse: Codable, Equatable {
    public let status: Status
    public let errorReason: ErrorReason?
    public let position: OrderPosition?

    public enum Status: String, Codable {
        case redeemed = "ok"
        case incomplete
        case error
    }

    public enum ErrorReason: String, Codable {
        case unpaid
        case alreadyRedeemed = "already_redeemed"
        case product
    }

    private enum CodingKeys: String, CodingKey {
        case status
        case errorReason = "reason"
        case position
    }
}
