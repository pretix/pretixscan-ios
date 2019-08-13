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
            optionButton.choiceID = option.identifier
            optionButton.tag = optionIndex
            buttons.append(optionButton)
            secondaryStackView.addArrangedSubview(optionButton)

            optionButton.addTarget(self, action: #selector(selected(sender:)), for: .touchUpInside)

            if answer?.answer == "\(optionButton.tag)" { optionButton.isSelected = true }
        }
    }

    @IBAction func selected(sender: UIButton) {
        buttons.forEach { $0.isSelected = false }
        sender.isSelected = true

        if let question = question, let choiceButton = sender as? ChoiceButton, let choiceID = choiceButton.choiceID {
            delegate?.answerUpdated(for: indexPath, newAnswer: Answer(question: question.identifier, answer: "\(choiceID)",
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
            buttons.filter({ return $0.isSelected })
                .compactMap({ if let choiceID = $0.choiceID { return "\(choiceID)," } else { return nil } })
                .forEach({ allTags += $0 })
            if allTags.count > 0 {
                // Cut off the last comma
                allTags = String(allTags.prefix(allTags.count - 1))
            }

            delegate?.answerUpdated(for: indexPath, newAnswer: Answer(question: question.identifier, answer: allTags,
                                                                      questionStringIdentifier: nil, options: [],
                                                                      optionStringIdentifiers: []))
        }
    }

    override func update() {
        super.update()

        let selectionList = answer?.answer.split(separator: ",") ?? []
        for button in buttons {
            button.isSelected = selectionList.contains("\(button.tag)")
        }
    }
}
