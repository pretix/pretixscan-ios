//
//  QuestionCell.swift
//  pretixSCAN
//
//  Created by Daniel Jilg on 15.07.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class QuestionCell: UITableViewCell {
    // MARK: Properties
    class var reuseIdentifier: String { return "QuestionCell" }

    var question: Question? { didSet { update() }}

    // MARK: View Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    private func update() {}
}

class NumberQuestionCell: QuestionCell {
    override class var reuseIdentifier: String { return "NumberQuestionCell" }
    // TODO
}

class OneLineStringQuestionCell: QuestionCell {
    override class var reuseIdentifier: String { return "OneLineStringQuestionCell" }
    // TODO
}

class MultiLineStringQuestionCell: QuestionCell {
    override class var reuseIdentifier: String { return "MultiLineStringQuestionCell" }
    // TODO
}

class BoolQuestionCell: QuestionCell {
    override class var reuseIdentifier: String { return "BoolQuestionCell" }
    // TODO
}

class SingleChoiceQuestionCell: QuestionCell {
    override class var reuseIdentifier: String { return "SingleChoiceQuestionCell" }
    // TODO
}

class MultipleChoiceQuestionCell: QuestionCell {
    override class var reuseIdentifier: String { return "MultipleChoiceQuestionCell" }
    // TODO
}

class FileUploadQuestionCell: QuestionCell {
    override class var reuseIdentifier: String { return "FileUploadQuestionCell" }
    // TODO
}

class DateQuestionCell: QuestionCell {
    override class var reuseIdentifier: String { return "DateQuestionCell" }
    // TODO
}

class TimeQuestionCell: QuestionCell {
    override class var reuseIdentifier: String { return "TimeQuestionCell" }
    // TODO
}

class DateTimeQuestionCell: QuestionCell {
    override class var reuseIdentifier: String { return "DateTimeQuestionCell" }
    // TODO
}

class CountryCodeQuestionCell: QuestionCell {
    override class var reuseIdentifier: String { return "CountryCodeQuestionCell" }
    // TODO
}
