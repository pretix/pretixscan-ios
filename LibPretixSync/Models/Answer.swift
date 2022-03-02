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
    public let question: Identifier

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
        self = Answer(question: questionIdentifier, answer: "", questionStringIdentifier: nil, options: [], optionStringIdentifiers: [], fileUrl: fileUrl)
    }
    
    init(question: Identifier, answer: String, questionStringIdentifier: String?, options: [Identifier], optionStringIdentifiers: [String]) {
        self = Answer(question: question, answer: answer, questionStringIdentifier: questionStringIdentifier, options: options, optionStringIdentifiers: optionStringIdentifiers, fileUrl: nil)
    }
}
