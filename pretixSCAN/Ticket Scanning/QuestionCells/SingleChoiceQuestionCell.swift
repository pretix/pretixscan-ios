//
//  SingleChoiceQuestionCell.swift
//  pretixSCAN
//
//  Created by Daniel Jilg on 13.08.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class SingleChoiceQuestionCell: QuestionCell {
    override class var reuseIdentifier: String { return "SingleChoiceQuestionCell" }

    var buttons: [ChoiceButton] = []

    let secondaryStackView: UIStackView = {
        let secondaryStackView = UIStackView()
        secondaryStackView.axis = .vertical
        secondaryStackView.distribution = UIStackView.Distribution.fill
        secondaryStackView.spacing = 8
        secondaryStackView.translatesAutoresizingMaskIntoConstraints = false
        return secondaryStackView
    }()

    override func setup() {
        super.setup()
        mainStackView.addArrangedSubview(secondaryStackView)
    }

    override func update() {
        super.update()

        for arrangedSubView in secondaryStackView.arrangedSubviews {
            secondaryStackView.removeArrangedSubview(arrangedSubView)
            arrangedSubView.removeFromSuperview()
        }

        buttons = []

        guard let question = question else { return }

        for optionIndex in 0..<question.options.count {
            let option = question.options[optionIndex]
            let optionButton = ChoiceButton()
            optionButton.setTitle(option.answer.representation(in: Locale.current), for: .normal)
            optionButton.tag = optionIndex
            buttons.append(optionButton)
            secondaryStackView.addArrangedSubview(optionButton)

            optionButton.addTarget(self, action: #selector(selected(sender:)), for: .touchUpInside)
        }
    }

    @IBAction func selected(sender: UIButton) {
        buttons.forEach { $0.isSelected = false }
        sender.isSelected = true

        if let question = question {
            delegate?.answerUpdated(for: indexPath, newAnswer: Answer(question: question.identifier, answer: "\(sender.tag)",
                questionStringIdentifier: nil, options: [], optionStringIdentifiers: []))
        }
    }
}

class MultipleChoiceQuestionCell: SingleChoiceQuestionCell {
    override class var reuseIdentifier: String { return "MultipleChoiceQuestionCell" }

    override func selected(sender: UIButton) {
        sender.isSelected.toggle()

        if let question = question {
            var allTags = ""
            buttons.filter({ return $0.isSelected }).map({ return "\($0.tag)," }).forEach({ allTags += $0 })

            delegate?.answerUpdated(for: indexPath, newAnswer: Answer(question: question.identifier, answer: allTags,
                                                                      questionStringIdentifier: nil, options: [],
                                                                      optionStringIdentifiers: []))
        }
    }
}
