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

    /// Status of the order (only set for live search in online mode)
    public let orderStatus: Order.Status?

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
    
    /// ID of the related subevent, if available
    public var extraSubEvent: SubEvent? 

    /// A random ID, e.g. for use in lead scanning apps
    public let pseudonymizationId: String

    /// List of check-ins with this ticket
    public let checkins: [CheckIn]

    /// Answers to user-defined questions
    public var answers: [Answer]?
    
    /// The assigned seat. Can be null.
    public let seat: Seat?
    
    public let requiresAttention: Bool?

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
        case orderStatus = "order__status"
        case checkins
        case answers
        case seat
        case requiresAttention = "require_attention"
    }

    public func adding(order: Order) -> OrderPosition {
        return OrderPosition(
            identifier: self.identifier,
            orderCode: self.orderCode,  orderStatus: order.status, order: order, positionid: self.positionid, itemIdentifier: self.itemIdentifier,
            item: self.item, variation: self.variation, price: self.price, attendeeName: self.attendeeName,
            attendeeEmail: self.attendeeEmail, secret: self.secret, subEvent: self.subEvent,
            pseudonymizationId: self.pseudonymizationId, checkins: self.checkins, answers: self.answers, seat: self.seat, requiresAttention: self.requiresAttention)
    }
    
    /// Create a RedemptionResponse by assuming the user wants to check in this OrderPosition in the provided CheckInList.
    ///
    /// @Note Note that the order position needs to be pre-filled with all its check-ins, items and order. See `FMDBDataStore.swift`'s
    ///       `redeem` function as an example.
    public func createRedemptionResponse(force: Bool, ignoreUnpaid: Bool, in event: Event, in checkInList: CheckInList, as type: String = "entry",
                                         with questions: [Question] = [], dataStore: DataStore? = nil) -> RedemptionResponse? {
        // Check if this ticket is for the correct sub event
        guard (checkInList.subEvent == nil || self.subEvent == checkInList.subEvent) else {
            return nil
        }

        // Check for products
        if !checkInList.allProducts {
            guard let limitProducts = checkInList.limitProducts, limitProducts.contains(self.itemIdentifier) else {
                return RedemptionResponse(status: .error, reasonExplanation: nil, errorReason: .product, position: self, lastCheckIn: nil, questions: nil,
                                          answers: nil)
            }
        }
        
        var status = self.orderStatus
        if self.order != nil {
            status = self.order!.status
        }

        // Check for order status
        if ![.paid, .pending].contains(status) {
            return RedemptionResponse(status: .error, reasonExplanation: nil, errorReason: .canceled, position: self, lastCheckIn: nil, questions: nil,
                                      answers: nil)
        }

        let shouldIgnoreUnpaid = ignoreUnpaid && checkInList.includePending
        if status == .pending, !shouldIgnoreUnpaid {
            return RedemptionResponse(status: .error, reasonExplanation: nil, errorReason: .unpaid, position: self, lastCheckIn: nil, questions: nil, answers: nil)
        }

        let lastCheckin = self.checkins.sorted { (a, b) -> Bool in
            return a.date < b.date
        }.last
        
        let allow: Bool = (
            type == "exit" ||
            checkInList.allowMultipleEntries ||
            lastCheckin == nil ||
            (checkInList.allowEntryAfterExit && lastCheckin!.type == "exit")
        )
        
        // Check for previous check ins
        if !allow && !force {
            // Attendee is already checked in
            return RedemptionResponse(status: .error, reasonExplanation: nil, errorReason: .alreadyRedeemed, position: self,
                                      lastCheckIn: self.checkins.last, questions: nil, answers: nil)
        }
        
        if type != "exit" {
            if case .failure(_) = TicketJsonLogicChecker(list: checkInList, dataStore: dataStore, event: event, subEvent: self.extraSubEvent, date: Date()).redeem(ticket: .init(secret: secret, eventSlug: event.slug, item: self.itemIdentifier, variation: self.variation)) {
                return .rules
            }
        }

        // Check if questions were never answered
        if answers == nil && questions.count > 0 {
            return RedemptionResponse(status: .incomplete, reasonExplanation: nil, errorReason: nil, position: self, lastCheckIn: nil,
                                      questions: questions, answers: answers)
        }

        // Check for open Questions
        let answerQuestionIDs: [Identifier] = answers?.map { return $0.question } ?? []
        let unansweredQuestions = questions.filter { return !answerQuestionIDs.contains($0.identifier) }
        let requiredUnansweredQuestions = unansweredQuestions.filter { $0.isRequired }
        if requiredUnansweredQuestions.count > 0 {
            return RedemptionResponse(status: .incomplete, reasonExplanation: nil, errorReason: nil, position: self, lastCheckIn: nil,
                                      questions: unansweredQuestions, answers: answers)
        }

        // Check that Boolean Questions with `isRequired` are answered true
        let booleanRequiredQuestions = questions.filter { $0.type == .boolean && $0.isRequired }
        let booleanRequiredQuestionIDs = booleanRequiredQuestions.map { $0.identifier }
        let badBools = answers?.filter { booleanRequiredQuestionIDs.contains($0.question) }.filter { $0.answer.lowercased() != "true" }
        if badBools?.count ?? 0 > 0 {
            return RedemptionResponse(status: .incomplete, reasonExplanation: nil, errorReason: nil, position: self, lastCheckIn: nil,
                                      questions: booleanRequiredQuestions, answers: answers)
        }

        // Return a positive redemption response
        return RedemptionResponse.redeemed
    }
}
