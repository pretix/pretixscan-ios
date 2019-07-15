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

    private let mainStackView = UIStackView()
    private let questionTypeLabel = UILabel()
    private let questionTextLabel = UILabel()

    // MARK: View Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        // Main Stack View
        mainStackView.axis = .vertical
        mainStackView.spacing = 8

        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainStackView)
        mainStackView.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1).isActive = true
        contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: mainStackView.bottomAnchor, multiplier: 1).isActive = true
        mainStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 1).isActive = true
        contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: mainStackView.trailingAnchor, multiplier: 1).isActive = true

        // Question Type Label
        questionTypeLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        questionTypeLabel.textColor = Color.secondary
        questionTypeLabel.text = reuseIdentifier?.uppercased()
        mainStackView.addArrangedSubview(questionTypeLabel)

        // Question Text Label
        questionTextLabel.numberOfLines = 0
        mainStackView.addArrangedSubview(questionTextLabel)
    }

    private func update() {
        questionTextLabel.text = question?.question.representation(in: Locale.current)
    }
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
