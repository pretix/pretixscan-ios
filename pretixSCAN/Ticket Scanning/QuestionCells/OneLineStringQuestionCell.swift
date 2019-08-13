//
//  OneLineStringQuestionCell.swift
//  pretixSCAN
//
//  Created by Daniel Jilg on 13.08.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class OneLineStringQuestionCell: QuestionCell, UITextFieldDelegate {
    override class var reuseIdentifier: String { return "OneLineStringQuestionCell" }

    let textField: UITextField = {
        let textField = UITextField()
        return textField
    }()

    override func setup() {
        super.setup()
        mainStackView.addArrangedSubview(PaddingView(enclosing: textField))
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let question = question, let textFieldText = textField.text {
            delegate?.answerUpdated(for: indexPath, newAnswer: Answer(question: question.identifier, answer: textFieldText,
                                                                      questionStringIdentifier: nil,
                                                                      options: [], optionStringIdentifiers: []))
        }
        return true
    }
}
