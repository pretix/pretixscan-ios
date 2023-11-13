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
    
    /// In case of reason rules includes a human-readable description of the violated rules.
    public let reasonExplanation: String?
    
    /// The reason for `status` being `error`, if applicable
    public let errorReason: ErrorReason?
    
    /// The `OrderPosition` being redeemed
    public var position: OrderPosition?
    
    /// A description of the item being redeemed which may be set during dataless validation when order position is unavailable
    public var datalessDescription: String? = nil
    
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
    
    /// When a negative redemption response is created the validation reason can optionally indicate the specific codepath resulting in the error code. This is being added to aid troubleshooting https://code.rami.io/pretix/pretixscan-ios/-/issues/62 and should only be used to aid debugging.
    public var _validationReason: TicketValidationReason = .unknown
    
    /// If `true`, the check-in app should show a warning that this
    /// ticket requires special attention if a ticket of this order is scanned.
    public var checkInAttention: Bool? = nil
    
    public var checkInTexts: [String]? = nil
    
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
        
        /// A custom rules has forbidden the scan
        case rules
        
        /// The ticket signature has been revoked
        case revoked
        
        /// The ticket signature or event reference is not correct
        case invalid
        
        case ambiguous
        
        case blocked
        
        case invalidTime = "invalid_time"
    }
    
    private enum CodingKeys: String, CodingKey {
        case status
        case errorReason = "reason"
        case position
        case lastCheckIn
        case questions
        case reasonExplanation = "reason_explanation"
        case checkInAttention = "require_attention"
        case checkInTexts = "checkin_texts"
    }
}


extension RedemptionResponse {
    var localizedErrorReason: String {
        guard let reason = self.errorReason else {
            return ""
        }
        switch reason {
        case .rules, .invalidTime:
            if let explanation = reasonExplanation {
                return "\(reason.localizedDescription()): \(explanation)".trimmingCharacters(in: .whitespacesAndNewlines)
            }
            return reason.localizedDescription()
        default:
            return reason.localizedDescription()
        }
    }
}


extension RedemptionResponse {
    static var invalid: Self {
        RedemptionResponse(status: .error, reasonExplanation: nil, errorReason: .invalid, questions: nil)
    }
    
    static var redeemed: Self {
        RedemptionResponse(status: .redeemed, reasonExplanation: nil, errorReason: nil, questions: nil)
    }
    
    static func redeemed(with orderPosition: OrderPosition) -> Self {
        var response = RedemptionResponse(status: .redeemed, reasonExplanation: nil, errorReason: nil, questions: nil)
        return appendDataFromOfflineMetadataForStatusVisualization(response, orderPosition: orderPosition)
    }
    
    static func redeemed(_ item: Item, variation: ItemVariation?) -> Self {
        return appendDataFromOfflineMetadataForStatusVisualization(Self.redeemed, item: item, variation: variation)
    }
    
    static var alreadyRedeemed: Self {
        RedemptionResponse(status: .error, reasonExplanation: nil, errorReason: .alreadyRedeemed, questions: nil)
    }
    
    static func alreadyRedeemed(_ item: Item, variation: ItemVariation?) -> Self {
        return appendDataFromOfflineMetadataForStatusVisualization(Self.alreadyRedeemed, item: item, variation: variation)
    }
    
    static func alreadyRedeemed(with orderPosition: OrderPosition) -> Self {
        return appendDataFromOfflineMetadataForStatusVisualization(Self.alreadyRedeemed, orderPosition: orderPosition)
    }
    
    static func appendDataFromOnlineQuestionsForStatusVisualization(_ redemptionResponse: RedemptionResponse) -> RedemptionResponse {
        var response = redemptionResponse
        var newTexts = [String]()
        
        let questionTexts = redemptionResponse.position?.answers?
            .filter({
                switch $0.question {
                case .identifier(_):
                    false
                case .questionDetail(let questionDetail):
                    questionDetail.showDuringCheckIn ?? false
                }
            })
            .map({
                "\($0.question.displayQuestion): \($0.answer)"
            }) ?? []
        newTexts.append(contentsOf: questionTexts)
        if !newTexts.isEmpty {
            if response.checkInTexts == nil {
                response.checkInTexts = []
            }
            response.checkInTexts!.append(contentsOf: newTexts)
        }
        return response
    }
    
    static func appendDataFromOfflineMetadataForStatusVisualization(_ redemptionResponse: RedemptionResponse, orderPosition: OrderPosition) -> RedemptionResponse {
        var response = redemptionResponse
        response.position = orderPosition
        if (orderPosition.item?.checkInAttention == true || orderPosition.calculatedVariation?.checkInAttention == true) {
            response.checkInAttention = true
        }
        
        var newTexts = [String]()
        // check-in messages from order, variation and item
        if let checkInText = orderPosition.order?.checkInText?.trimmingCharacters(in: .whitespacesAndNewlines), !checkInText.isEmpty {
            newTexts.append(checkInText)
        }
        if let checkInText = orderPosition.calculatedVariation?.checkInText?.trimmingCharacters(in: .whitespacesAndNewlines), !checkInText.isEmpty {
            newTexts.append(checkInText)
        }
        if let checkInText = orderPosition.item?.checkInText?.trimmingCharacters(in: .whitespacesAndNewlines), !checkInText.isEmpty {
            newTexts.append(checkInText)
        }
        if !newTexts.isEmpty {
            response.checkInTexts = newTexts
        }
        
        // check-in messages from questions
        response = appendDataFromOnlineQuestionsForStatusVisualization(response)
        return response
    }
    
    
    static func appendDataFromOfflineMetadataForStatusVisualization(_ redemptionResponse: RedemptionResponse, item: Item, variation: ItemVariation?) -> RedemptionResponse {
        var response = redemptionResponse
        response.setDatalessDescription(item, variation: variation)
        response.checkInAttention = item.checkInAttention || variation?.checkInAttention == true
        response.checkInTexts = response.checkInTexts ?? []
        
        var newTexts = [String]()
        // check-in messages from order, variation and item
        if let checkInText = variation?.checkInText?.trimmingCharacters(in: .whitespacesAndNewlines), !checkInText.isEmpty {
            newTexts.append(checkInText)
        }
        if let checkInText = item.checkInText?.trimmingCharacters(in: .whitespacesAndNewlines), !checkInText.isEmpty {
            newTexts.append(checkInText)
        }
        if !newTexts.isEmpty {
            response.checkInTexts = newTexts
        }
        
        // check-in messages from questions
        response = appendDataFromOnlineQuestionsForStatusVisualization(response)
        
        return response
    }
    
    static var revoked: Self {
        RedemptionResponse(status: .error, reasonExplanation: nil, errorReason: .revoked, questions: nil)
    }
    
    static var product: Self {
        RedemptionResponse(status: .error, reasonExplanation: nil, errorReason: .product, questions: nil)
    }
    
    static var rules: Self {
        RedemptionResponse(status: .error, reasonExplanation: nil, errorReason: .rules, questions: nil)
    }
    
    static var ambiguous: Self {
        RedemptionResponse(status: .error, reasonExplanation: nil, errorReason: .ambiguous, questions: nil)
    }
    
    static var blocked: Self {
        RedemptionResponse(status: .error, reasonExplanation: nil, errorReason: .blocked, questions: nil)
    }
    
    static var invalidTime: Self {
        RedemptionResponse(status: .error, reasonExplanation: nil, errorReason: .invalidTime, questions: nil)
    }
    
    init(incompleteQuestions: [Question], _ answers: [Answer]?) {
        self = RedemptionResponse(status: .incomplete, reasonExplanation: nil, errorReason: nil, position: nil, lastCheckIn: nil, questions: incompleteQuestions, answers: answers, checkInAttention: nil)
    }
}


extension RedemptionResponse {
    var isRequireAttention: Bool {
        self.checkInAttention == true || position?.order?.checkInAttention == true || position?.item?.checkInAttention == true || position?.calculatedVariation?.checkInAttention == true
    }
}


extension RedemptionResponse {
    mutating func setDatalessDescription(_ item: Item, variation: ItemVariation?) {
        var label: String? = nil
        
        if let itemName = item.name.representation(in: Locale.current) {
            label = itemName
        }
        
        if let variationName = variation?.name.representation(in: Locale.current) {
            if var label = label {
                label = "\(label) – \(variationName)"
            } else {
                label = variationName
            }
        }
        
        self.datalessDescription = label
    }
    
    /// Returns a human readable product label based on the order position or any item and variation details available during validation. If no information s found, returns an emtpy string
    var calculatedProductLabel: String {
        if let position = self.position {
            return position.calculatedProductLabel
        }
        return datalessDescription ?? ""
    }
}
