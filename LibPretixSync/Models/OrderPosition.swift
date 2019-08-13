//
//  OrderPosition.swift
//  PretixScan
//
//  Created by Daniel Jilg on 19.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

/// Part of an Order
public struct OrderPosition: Model {
    public static let humanReadableName = "Order Position"
    public static let stringName = "orderpositions"

    /// Internal ID of the order position
    public let identifier: Identifier

    /// Order code of the order the position belongs to
    public let orderCode: String

    /// The `Order` this position belongs to.
    ///
    /// (May be nil if not pre-fetched by the database. Fall back on `orderCode` in that case)
    public var order: Order?

    /// Number of the position within the order
    public let positionid: Identifier

    /// ID of the purchased item
    public let itemIdentifier: Identifier

    /// The purchased `Item`.
    ///
    /// (May be nil if not pre-fetched by the database. Fall back on `itemIdentifier` in that case)
    public var item: Item?

    /// ID of the purchased variation (if any)
    public let variation: Identifier?

    /// Price of this position
    public let price: Money

    /// Specified attendee name for this position
    public let attendeeName: String?

    /// Specified attendee email address for this position
    public let attendeeEmail: String?

    /// Secret code printed on the tickets for validation
    public let secret: String

    /// ID of the date inside an event series this position belongs to, if any
    public let subEvent: Identifier?

    /// A random ID, e.g. for use in lead scanning apps
    public let pseudonymizationId: String

    /// List of check-ins with this ticket
    public let checkins: [CheckIn]

    /// Answers to user-defined questions
    public var answers: [Answer]

    /// Ticket has already been used
    public var isRedeemed: Bool {
        return checkins.count > 0
    }

    public var calculatedVariation: ItemVariation? {
        guard let variationIdentifier = variation else { return nil }
        return item?.variations.filter({ $0.identifier == variationIdentifier }).first
    }

    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case orderCode = "order"
        case positionid
        case itemIdentifier = "item"
        case variation
        case price
        case attendeeName = "attendee_name"
        case attendeeEmail = "attendee_email"
        case secret
        case subEvent = "subevent"
        case pseudonymizationId = "pseudonymization_id"
        case checkins
        case answers
    }

    /// Create a RedemptionResponse by assuming the user wants to check in this OrderPosition in the provided CheckInList.
    ///
    /// @Note Note that the order position needs to be pre-filled with all its check-ins, items and order. See `FMDBDataStore.swift`'s
    ///       `redeem` function as an example.
    public func createRedemptionResponse(force: Bool, ignoreUnpaid: Bool, in event: Event, in checkInList: CheckInList,
                                         with questions: [Question] = []) -> RedemptionResponse? {
        // Check if this ticket is for the correct sub event
        guard self.subEvent == checkInList.subEvent else {
            return nil
        }

        // Check for products
        if !checkInList.allProducts {
            guard let limitProducts = checkInList.limitProducts, limitProducts.contains(self.itemIdentifier) else {
                return RedemptionResponse(status: .error, errorReason: .product, position: self, lastCheckIn: nil, questions: nil)
            }
        }

        // Check for order status
        if ![.paid, .pending].contains(self.order!.status) {
            return RedemptionResponse(status: .error, errorReason: .canceled, position: self, lastCheckIn: nil, questions: nil)
        }

        let shouldIgnoreUnpaid = ignoreUnpaid && checkInList.includePending
        if self.order!.status == .pending, !shouldIgnoreUnpaid {
            return RedemptionResponse(status: .error, errorReason: .unpaid, position: self, lastCheckIn: nil, questions: nil)
        }

        // Check for previous check ins
        if self.checkins.count > 0, !force {
            // Attendee is already checked in
            return RedemptionResponse(status: .error, errorReason: .alreadyRedeemed, position: self,
                                      lastCheckIn: self.checkins.last, questions: nil)
        }

        // Check for open Questions
        let answerQuestionIDs = answers.map { return $0.question }
        let unansweredQuestions = questions.filter { return !answerQuestionIDs.contains($0.identifier) }.filter { $0.isRequired }
        if unansweredQuestions.count > 0 {
            return RedemptionResponse(status: .incomplete, errorReason: nil, position: self, lastCheckIn: nil,
                                      questions: unansweredQuestions)
        }

        // Check that Boolean Questions with `isRequired` are answered true
        let booleanRequiredQuestions = questions.filter { $0.type == .boolean && $0.isRequired }
        let booleanRequiredQuestionIDs = booleanRequiredQuestions.map { $0.identifier }
        let badBools = answers.filter { booleanRequiredQuestionIDs.contains($0.question) }.filter { $0.answer.lowercased() != "true" }
        if badBools.count > 0 {
            return RedemptionResponse(status: .incomplete, errorReason: nil, position: self, lastCheckIn: nil,
                                      questions: booleanRequiredQuestions)
        }

        // Return a positive redemption response
        return RedemptionResponse(status: .redeemed, errorReason: nil, position: self, lastCheckIn: nil, questions: nil)
    }
}
