//
//  QuestionCell.swift
//  pretixSCAN
//
//  Created by Daniel Jilg on 15.07.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

protocol QuestionCellDelegate: class {
    func answerUpdated(for indexPath: IndexPath?, newAnswer: Answer?)
}

/// Base Class for Question Cells. See subclasses for actual implementation.
class QuestionCell: UITableViewCell {
    // MARK: Properties
    class var reuseIdentifier: String { return "QuestionCell" }

    var indexPath: IndexPath?
    var question: Question? { didSet { update() }}
    var answer: Answer? { didSet { update() }}
    weak var delegate: QuestionCellDelegate?

    let mainStackView: UIStackView = {
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.spacing = 8
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        return mainStackView
    }()

    let questionTypeLabel: UILabel = {
        let questionTypeLabel = UILabel()
        questionTypeLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        questionTypeLabel.textColor = Color.secondary
        return questionTypeLabel
    }()

    let questionTextLabel: UILabel = {
        let questionTextLabel = UILabel()
        questionTextLabel.numberOfLines = 0
        return questionTextLabel
    }()

    // MARK: View Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        contentView.addSubview(mainStackView)
        mainStackView.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1).isActive = true
        contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: mainStackView.bottomAnchor, multiplier: 1).isActive = true
        mainStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 1).isActive = true
        contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: mainStackView.trailingAnchor, multiplier: 1).isActive = true

        mainStackView.addArrangedSubview(questionTypeLabel)
        mainStackView.addArrangedSubview(questionTextLabel)
    }

    func update() {
        questionTypeLabel.text = NSLocalizedString(reuseIdentifier ?? "", comment: "").uppercased()
        questionTextLabel.text = question?.question.representation(in: Locale.current)
    }
}
