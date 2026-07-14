//
//  CheckInRequest.swift
//  pretixSCAN
//
//  Created by Konstantin on 29/03/2023.
//  Copyright © 2023 rami.io. All rights reserved.
//

import Foundation

public struct CheckInRequest: Codable {
    public init(list: Identifier, secret: String, redemptionRequest: RedemptionRequest) {
        self.init(secret: secret, lists: [list], type: CheckInType(rawValue: redemptionRequest.type)!, dateTime: redemptionRequest.date, force: redemptionRequest.force, ignoreUnpaid: redemptionRequest.ignoreUnpaid, answers: redemptionRequest.answers, nonce: redemptionRequest.nonce, sourceType: redemptionRequest.sourceType)
    }

    public init(secret: String, lists: [Identifier], type: CheckInType, dateTime: Date? = nil, force: Bool, ignoreUnpaid: Bool, answers: [String: String]? = nil, nonce: String, sourceType: String = "barcode") {
        self.secret = secret
        self.lists = lists
        self.type = type
        self.dateTime = dateTime
        self.force = force
        self.questionsSupported = true
        self.ignoreUnpaid = ignoreUnpaid
        self.answers = answers
        self.nonce = nonce
        self.sourceType = sourceType
    }
    
    public var secret: String
    public var lists: [Identifier]
    public var type: CheckInType
    public var dateTime: Date?
    public var force: Bool
    public var questionsSupported: Bool
    public var ignoreUnpaid: Bool
    public var answers: [String: String]?
    public var nonce: String
    public var sourceType: String = "barcode"

    enum CodingKeys: String, CodingKey {
        case secret
        case lists
        case type
        case dateTime = "datetime"
        case force
        case questionsSupported = "questions_supported"
        case ignoreUnpaid = "ignore_unpaid"
        case answers
        case nonce
        case sourceType = "source_type"
    }
}


public enum CheckInType: String, Codable {
    case entry
    case exit
}
