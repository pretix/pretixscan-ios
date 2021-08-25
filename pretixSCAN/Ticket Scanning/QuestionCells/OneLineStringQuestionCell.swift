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
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    override func update() {
        super.update()
        textField.text = answer?.answer
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let question = question, let textFieldText = textField.text {
            print("text field updating answer to \(textFieldText)")
            delegate?.answerUpdated(for: indexPath, newAnswer: Answer(question: question.identifier, answer: textFieldText,
                                                                      questionStringIdentifier: nil,
                                                                      options: [], optionStringIdentifiers: []))
        }
    }
    
}
