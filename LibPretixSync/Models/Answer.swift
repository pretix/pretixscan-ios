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
    public let answer: String

    /// The question’s `identifier` field
    public let questionStringIdentifier: String?

    /// Internal IDs of selected option(s)s (only for choice types)
    public let options: [Identifier]

    /// The identifier fields of the selected option(s)s
    public let optionStringIdentifiers: [String]

    // MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
        case question
        case answer
        case questionStringIdentifier = "question_identifier"
        case options
        case optionStringIdentifiers = "option_identifiers"
    }
}
