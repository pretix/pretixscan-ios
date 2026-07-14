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
    public var questionsSupported: Bool = true

    /// Wether the current device supports the "canceled" state. This is always true
    /// for this implementation.
    public var canceledSupported: Bool = true

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
    public var answers: [String: String]?
    
    public let type: String

    /// Type of source the secret was obtained from, e.g. "barcode" or "nfc_uid". Defaults to "barcode".
    public var sourceType: String = "barcode"

    init(questionsSupported: Bool = true, date: Date?, force: Bool = false, ignoreUnpaid: Bool, nonce: String,
         answers: [Answer]? = nil, type: String, sourceType: String = "barcode") {
        self.questionsSupported = questionsSupported
        self.date = date
        self.force = force
        self.ignoreUnpaid = ignoreUnpaid
        self.nonce = nonce
        self.type = type
        self.sourceType = sourceType

        guard let answers = answers else {
            self.answers = nil
            return
        }

        var answerDict = [String: String]()
        for answer in answers {
            if let fileUrl = answer.fileUrl {
                answerDict["\(answer.question.id)"] = PXTemporaryFile.addPathPrefix(fileUrl)
            } else {
                answerDict["\(answer.question.id)"] = answer.answer
            }
        }
        self.answers = answerDict
    }

    private enum CodingKeys: String, CodingKey {
        case questionsSupported = "questions_supported"
        case canceledSupported = "canceled_supported"
        case date = "datetime"
        case force
        case ignoreUnpaid = "ignore_unpaid"
        case type
        case nonce
        case answers
        case sourceType = "source_type"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        questionsSupported = try container.decodeIfPresent(Bool.self, forKey: .questionsSupported) ?? true
        canceledSupported = try container.decodeIfPresent(Bool.self, forKey: .canceledSupported) ?? true
        date = try container.decodeIfPresent(Date.self, forKey: .date)
        force = try container.decodeIfPresent(Bool.self, forKey: .force) ?? false
        ignoreUnpaid = try container.decode(Bool.self, forKey: .ignoreUnpaid)
        nonce = try container.decode(String.self, forKey: .nonce)
        answers = try container.decodeIfPresent([String: String].self, forKey: .answers)
        type = try container.decode(String.self, forKey: .type)
        sourceType = try container.decodeIfPresent(String.self, forKey: .sourceType) ?? "barcode"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(questionsSupported, forKey: .questionsSupported)
        try container.encode(canceledSupported, forKey: .canceledSupported)
        try container.encodeIfPresent(date, forKey: .date)
        try container.encode(force, forKey: .force)
        try container.encode(ignoreUnpaid, forKey: .ignoreUnpaid)
        try container.encode(nonce, forKey: .nonce)
        try container.encodeIfPresent(answers, forKey: .answers)
        try container.encode(type, forKey: .type)
        try container.encode(sourceType, forKey: .sourceType)
    }
}

extension RedemptionRequest: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(date)
        hasher.combine(force)
        hasher.combine(ignoreUnpaid)
        hasher.combine(nonce)
        hasher.combine(type)
    }
}
