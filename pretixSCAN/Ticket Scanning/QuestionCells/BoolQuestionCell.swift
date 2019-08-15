//
//  BoolQuestionCell.swift
//  pretixSCAN
//
//  Created by Daniel Jilg on 13.08.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class BoolQuestionCell: QuestionCell {
    override class var reuseIdentifier: String { return "BoolQuestionCell" }

    let secondaryStackView: UIStackView = {
        let secondaryStackView = UIStackView()
        secondaryStackView.axis = .horizontal
        secondaryStackView.distribution = .fillEqually
        secondaryStackView.spacing = 8
        secondaryStackView.translatesAutoresizingMaskIntoConstraints = false
        return secondaryStackView
    }()

    let onButton: ChoiceButton = {
        let onButton = ChoiceButton()
        onButton.setTitle(Localization.QuestionCells.booleanYes, for: .normal)
        return onButton
    }()

    let offButton: ChoiceButton = {
        let offButton = ChoiceButton()
        offButton.setTitle(Localization.QuestionCells.booleanNo, for: .normal)
        return offButton
    }()

    override func setup() {
        super.setup()
        mainStackView.addArrangedSubview(secondaryStackView)
        secondaryStackView.addArrangedSubview(onButton)
        secondaryStackView.addArrangedSubview(offButton)

        onButton.addTarget(self, action: #selector(selected(sender:)), for: .touchUpInside)
        offButton.addTarget(self, action: #selector(selected(sender:)), for: .touchUpInside)
    }

    override func update() {
        super.update()
        onButton.isSelected = answer?.answer == "true"
        offButton.isSelected = answer?.answer == "false"
    }

    @IBAction func selected(sender: UIButton) {
        [onButton, offButton].forEach { $0.isSelected = false }
        sender.isSelected = true

        // Don't allow "No" if the question is required
        if question?.isRequired == true && sender == offButton {
            sender.isSelected = false
            let animation = CAKeyframeAnimation(keyPath: "position.x")
            animation.values = [ 0, 5, -5, 5, 0 ]
            animation.keyTimes = [ 0, NSNumber(value: (1 / 6.0)), NSNumber(value: (3 / 6.0)), NSNumber(value: (5 / 6.0)), 1 ]
            animation.duration = 0.2
            animation.isAdditive = true
            sender.layer.add(animation, forKey: "shake")

            delegate?.answerUpdated(for: indexPath, newAnswer: nil)
            return
        }

        if let question = question {
            delegate?.answerUpdated(for: indexPath, newAnswer: Answer(question: question.identifier,
                                                                      answer: onButton.isSelected ? "true" : "false",
                                                                      questionStringIdentifier: nil, options: [],
                                                                      optionStringIdentifiers: []))
        }
    }
}
