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
        onButton.setTitle("1", for: .normal)
        return onButton
    }()

    let offButton: ChoiceButton = {
        let offButton = ChoiceButton()
        offButton.setTitle("0", for: .normal)
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

    @IBAction func selected(sender: UIButton) {
        [onButton, offButton].forEach { $0.isSelected = false }
        sender.isSelected = true

        if let question = question {
            delegate?.answerUpdated(for: indexPath, newAnswer: Answer(question: question.identifier,
                                                                      answer: onButton.isSelected ? "true" : "false",
                                                                      questionStringIdentifier: nil, options: [],
                                                                      optionStringIdentifiers: []))
        }
    }
}
