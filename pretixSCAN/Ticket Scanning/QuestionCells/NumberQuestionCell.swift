//
//  NumberQuestionCell.swift
//  pretixSCAN
//
//  Created by Daniel Jilg on 13.08.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class NumberQuestionCell: QuestionCell, UITextFieldDelegate {
    override class var reuseIdentifier: String { return "NumberQuestionCell" }

    let numberTextField: UITextField = {
        let numberTextField = UITextField()
        numberTextField.keyboardType = UIKeyboardType.decimalPad
        return numberTextField
    }()

    override func setup() {
        super.setup()

        numberTextField.delegate = self
        mainStackView.addArrangedSubview(PaddingView(enclosing: numberTextField))
    }

    override func update() {
        super.update()
        numberTextField.text = answer?.answer
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let aSet = NSCharacterSet(charactersIn: "0123456789").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")

        if string == numberFiltered {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

            // only allow 14 or less digits
            let allowEdit = updatedText.count <= 14

            if let question = question, allowEdit {
                let answer = Answer(question: question.identifier, answer: updatedText, questionStringIdentifier: nil,
                                    options: [], optionStringIdentifiers: [])
                delegate?.answerUpdated(for: indexPath, newAnswer: answer)
            }
            return allowEdit

        } else {
            return false
        }
    }
}
