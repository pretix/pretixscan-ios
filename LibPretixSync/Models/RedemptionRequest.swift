//
//  RedemptionRequest.swift
//  PretixScan
//
//  Created by Daniel Jilg on 20.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

/// Tries to redeem an order position, identified by its internal ID, i.e. checks the attendee in.
///
/// - See also `RedemptionResponse`
/// - See also `QueuedRedemptionRequest`
public struct RedemptionRequest: Model {
    public static var humanReadableName = "Redemption Request"
    public static var stringName = "redemption_requests"

    /// Wether the current device supports handling questions
    ///
    /// When this parameter is set to `true`, handling of questions is supported.
    /// If you do not implement question handling in your user interface, you must
    /// set this to `false`. In that case, questions will just be ignored. Defaults
    /// to `true` in the API, but set to false until this app implements questions
    /// handling.
    public var questionsSupported: Bool = false

    /// Specifies the datetime of the check-in.
    ///
    /// If not supplied, the current time will be used.
    public let date: Date?

    /// Specifies that the check-in should succeed regardless of previous check-ins or required
    /// questions that have not been filled.
    ///
    /// Defaults to `false`.
    public var force: Bool = false

    /// Ignore Ticket Unpaid Status
    ///
    /// Specifies that the check-in should succeed even if the order is in pending state. Defaults to `false`.
    public let ignoreUnpaid: Bool

    /// Number Only used Once
    ///
    /// You can set this parameter to a unique random value to identify this check-in. If you’re
    /// sending this request twice with the same nonce, the second request will also succeed but
    /// will always create only one check-in object even when the previous request was successful
    /// as well. This allows for a certain level of idempotency and enables you to re-try after
    /// a connection failure.
    public let nonce: String

    // If questions are supported/required, you may/must supply a mapping of question IDs to their
    // respective answers. The answers should always be strings. In case of (multiple-)choice-type
    // answers, the string should contain the (comma-separated) IDs of the selected options.
    public let answers: [String: String]?

    init(questionsSupported: Bool = true, date: Date?, force: Bool = false, ignoreUnpaid: Bool, nonce: String,
         answers: [String: String]? = nil) {
        self.questionsSupported = questionsSupported
        self.date = date
        self.force = force
        self.ignoreUnpaid = ignoreUnpaid
        self.nonce = nonce
        self.answers = answers
    }

    private enum CodingKeys: String, CodingKey {
        case questionsSupported = "questions_supported"
        case date = "datetime"
        case force
        case ignoreUnpaid = "ignore_unpaid"
        case nonce
        case answers

    }
}

extension RedemptionRequest: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(date)
        hasher.combine(force)
        hasher.combine(ignoreUnpaid)
        hasher.combine(nonce)
    }
}
