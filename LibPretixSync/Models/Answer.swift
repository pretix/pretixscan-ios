//
//  Answer.swift
//  pretixSCAN
//
//  Created by Daniel Jilg on 02.07.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

/// Answer to user-defined questions
public struct Answer: Model {
    public static var humanReadableName = "Answer"
    public static var stringName = "answers"
    
    /// Internal ID of the answered question
    public let question: QuestionType
    
    /// Text representation of the answer
    public var answer: String
    
    /// The question’s `identifier` field
    public let questionStringIdentifier: String?
    
    /// Internal IDs of selected option(s)s (only for choice types)
    public let options: [Identifier]
    
    /// The identifier fields of the selected option(s)s
    public let optionStringIdentifiers: [String]
    
    /// URL to a local file which should be uploaded as the payload for this answer
    public var fileUrl: URL?
    
    // MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
        case question
        case answer
        case questionStringIdentifier = "question_identifier"
        case options
        case optionStringIdentifiers = "option_identifiers"
        case fileUrl
    }
}

extension Answer {
    init(questionIdentifier: Identifier, fileUrl: URL) {
        self = Answer(question: .identifier(questionIdentifier), answer: "", questionStringIdentifier: nil, options: [], optionStringIdentifiers: [], fileUrl: fileUrl)
    }
    
    init(question: Identifier, answer: String, questionStringIdentifier: String?, options: [Identifier], optionStringIdentifiers: [String]) {
        self = Answer(question: .identifier(question), answer: answer, questionStringIdentifier: questionStringIdentifier, options: options, optionStringIdentifiers: optionStringIdentifiers, fileUrl: nil)
    }
}

/// QuestionType handles the fact that the server will be sending either an integer or an object depending on different circumstances.
public enum QuestionType: Codable {
    case identifier(Identifier)
    case questionDetail(Question)
    
    var id: Identifier {
        switch self {
        case .identifier(let _id):
            _id
        case .questionDetail(let detail):
            detail.identifier
        }
    }
    
    var showDuringCheckIn: Bool {
        switch self {
        case .identifier(_):
            false
        case .questionDetail(let detail):
            detail.showDuringCheckIn ?? false
        }
    }
    
    var displayQuestion: String {
        switch self {
        case .identifier(_):
            ""
        case .questionDetail(let detail):
            detail.question.representation(in: Locale.current) ?? ""
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            self = .identifier(intValue)
        } else if let questionValue = try? container.decode(Question.self) {
            self = .questionDetail(questionValue)
        } else {
            throw DecodingError.typeMismatch(QuestionType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected Int or Question"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .identifier(let intValue):
            try container.encode(intValue)
        case .questionDetail(let questionValue):
            try container.encode(questionValue)
        }
    }
}

extension QuestionType: Equatable {
    public static func == (lhs: QuestionType, rhs: QuestionType) -> Bool {
        switch (lhs, rhs) {
        case (.identifier(let leftValue), .identifier(let rightValue)):
            return leftValue == rightValue
        case (.questionDetail(let leftValue), .questionDetail(let rightValue)):
            return leftValue == rightValue
        default:
            return false
        }
    }
}


extension QuestionType: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .identifier(let value):
            hasher.combine(0) // Discriminator for 'identifier' case
            hasher.combine(value)
        case .questionDetail(let value):
            hasher.combine(1) // Discriminator for 'questionDetail' case
            hasher.combine(value)
        }
    }
}
