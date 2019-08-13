//
//  MultiLineStringQuestionCell.swift
//  pretixSCAN
//
//  Created by Daniel Jilg on 13.08.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class MultiLineStringQuestionCell: QuestionCell, UITextViewDelegate {
    override class var reuseIdentifier: String { return "MultiLineStringQuestionCell" }

    let textView: UITextView = {
        let textView = UITextView()
        textView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        return textView
    }()

    override func setup() {
        super.setup()
        mainStackView.addArrangedSubview(PaddingView(enclosing: textView))
        textView.delegate = self
    }

    override func update() {
        super.update()
        textView.text = answer?.answer
    }

    func textViewDidChange(_ textView: UITextView) {
        if let question = question, let textFieldText = textView.text {
            delegate?.answerUpdated(for: indexPath, newAnswer: Answer(question: question.identifier, answer: textFieldText,
                                                                      questionStringIdentifier: nil,
                                                                      options: [], optionStringIdentifiers: []))
        }
    }
}
