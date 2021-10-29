//
//  Question.swift
//  pretixSCAN
//
//  Created by Daniel Jilg on 29.06.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

/// Questions define additional fields that need to be filled out by customers during checkout.
public struct Question: Model {
    // MARK: Model Meta
    public static var humanReadableName = "Question"
    public static var stringName = "questions"

    // MARK: - Fields
    /// Internal ID of the question
    public let identifier: Identifier

    /// The field label shown to the customer
    public let question: MultiLingualString

    /// The expected type of answer
    public let type: QuestionType

    /// If `true`, the question needs to be filled out.
    public let isRequired: Bool

    /// An integer used for sorting
    public let position: Int

    /// List of `Item` identifiers this question is assigned to.
    public let items: [Identifier]

    /// An arbitrary string that can be used for matching with other sources.
    public let stringIdentifier: String

    /// If true, this question will not be asked while buying the ticket, but will show up when redeeming the ticket instead.
    public let askDuringCheckIn: Bool

    /// If `true`, the question will only be shown in the backend.
    public let isHidden: Bool

    /// In case of (mulitple) choice questions, this lists the available choices
    public let options: [ChoiceOption]

    /// Internal ID of a different question.
    ///
    /// The current question will only be shown if the question given in this attribute is set to the value given in dependency_value.
    /// This cannot be combined with ask_during_checkin.
    public let dependencyQuestion: Identifier?

    /// The value `dependencyQuestion` needs to be set to.
    ///
    /// If dependency_question is set to a boolean question, this should be "true" or "false". Otherwise, it should be the identifier of a
    /// question option.
    public let dependencyValue: String?

    // MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case question
        case type
        case isRequired = "required"
        case position
        case items
        case stringIdentifier = "identifier"
        case askDuringCheckIn = "ask_during_checkin"
        case isHidden = "hidden"
        case options
        case dependencyQuestion = "dependency_question"
        case dependencyValue = "dependency_value"
    }

    // MARK: - Sub Types
    /// The expected type of answer
    public enum QuestionType: String, Codable, Equatable, Hashable, UnknownCase {
        public static var unknownCase = QuestionType.oneLineString
        
        /// number
        case number = "N"

        /// One Line String
        case oneLineString = "S"

        /// Multi Line String
        case multiLineString = "T"

        /// Yes/No Answer
        case boolean = "B"

        /// choice from a list
        case choiceFromList = "C"

        /// multiple choice from a list
        case multipleChoiceFromList = "M"

        /// File Upload
        case fileUpload = "F"

        /// Date
        case date = "D"

        /// Time
        case time = "H"

        /// Date and Time
        case dateAndTime = "W"

        /// country code (ISO 3666-1 alpha-2)
        case countryCode = "CC"
        
        /// Phone number in the format +<country code>
        case phone = "TEL"
    }

    /// Possible Answer Option for Choice Questions
    public struct ChoiceOption: Codable, Equatable, Hashable {
        /// Internal ID of the option
        public let identifier: Identifier

        /// An integer, used for sorting
        public let position: Int

        /// An arbitrary string that can be used for matching with other sources.
        public let stringIdentifier: String

        /// The displayed value of this option
        public let answer: MultiLingualString

        // swiftlint:disable:next nesting
        private enum CodingKeys: String, CodingKey {
            case identifier = "id"
            case position
            case stringIdentifier = "identifier"
            case answer
        }
    }
}
