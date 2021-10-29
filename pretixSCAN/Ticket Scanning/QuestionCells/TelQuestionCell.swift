//
//  TelQuestionCell.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 29/10/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//


import UIKit
import PhoneNumberKit

class TelQuestionCell: QuestionCell, UITextFieldDelegate {
    override class var reuseIdentifier: String { return "TelQuestionCell" }
    
    let textField: UITextField = {
        let textField = PhoneNumberTextField()
        textField.text = "+"
        textField.withExamplePlaceholder = true
        textField.withPrefix = true
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
    
    let phoneNumberKit = PhoneNumberKit()
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let question = question, let textFieldText = textField.text,  let parsedPhone = try? phoneNumberKit.parse(textFieldText) {
            let answer = phoneNumberKit.format(parsedPhone, toType: .e164)
            delegate?.answerUpdated(for: indexPath, newAnswer: Answer(question: question.identifier, answer: answer,
                                                                      questionStringIdentifier: nil,
                                                                      options: [], optionStringIdentifiers: []))
        }
    }
    
}
