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
    /// The server response to the redemption request
    public let status: Status

    /// The reason for `status` being `error`, if applicable
    public let errorReason: ErrorReason?

    /// The `OrderPosition` being redeemed
    public var position: OrderPosition?

    /// If the ticket has already been redeemed, this field might contain the last CheckIn
    public var lastCheckIn: CheckIn?

    /// If the ticket is incomplete, a list of questions that need to be answered
    public let questions: [Question]?

    /// A list of answers to be pre-filled.
    ///
    /// When answering questions, the request/respons cycle can go around a few times. The server will save the answers individually,
    /// but we don't want to do that while in offline mode. So instead, we return the already provided answers in this array, so they
    /// can be pre-filled in the UI, allowing the user to only answer the missing ones. 
    public var answers: [Answer]?

    // MARK: - Enums
    /// Possible values for the Response Status
    public enum Status: String, Codable {
        /// The ticket has been successfully redeemed and the attendee should be let in
        case redeemed = "ok"

        /// Some information is missing
        case incomplete

        /// An error occurred, check the `errorReason`
        case error
    }

    /// Possible reasons an error could occur
    public enum ErrorReason: String, Codable {
        /// The ticket was not yet paid
        case unpaid

        /// The ticket order was canceled
        case canceled

        /// The ticket was already used
        case alreadyRedeemed = "already_redeemed"

        /// The product is not available on this check in list
        case product
    }

    private enum CodingKeys: String, CodingKey {
        case status
        case errorReason = "reason"
        case position
        case lastCheckIn
        case questions
    }
}
