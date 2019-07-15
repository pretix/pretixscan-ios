//
//  QuestionCell.swift
//  pretixSCAN
//
//  Created by Daniel Jilg on 15.07.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class QuestionCell: UITableViewCell {
    // MARK: Properties
    class var reuseIdentifier: String { return "QuestionCell" }

    var question: Question? { didSet { update() }}

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
        questionTypeLabel.text = reuseIdentifier?.uppercased()
        questionTextLabel.text = question?.question.representation(in: Locale.current)
    }
}

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

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let aSet = NSCharacterSet(charactersIn: "0123456789").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")

        if string == numberFiltered {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

            // only allow 14 or less digits
            return updatedText.count <= 14
        } else {
            return false
        }
    }
}

class OneLineStringQuestionCell: QuestionCell {
    override class var reuseIdentifier: String { return "OneLineStringQuestionCell" }
    // TODO
}

class MultiLineStringQuestionCell: QuestionCell {
    override class var reuseIdentifier: String { return "MultiLineStringQuestionCell" }
    // TODO
}

class BoolQuestionCell: QuestionCell {
    override class var reuseIdentifier: String { return "BoolQuestionCell" }
    // TODO
}

class SingleChoiceQuestionCell: QuestionCell {
    override class var reuseIdentifier: String { return "SingleChoiceQuestionCell" }
    // TODO
}

class MultipleChoiceQuestionCell: QuestionCell {
    override class var reuseIdentifier: String { return "MultipleChoiceQuestionCell" }
    // TODO
}

class FileUploadQuestionCell: QuestionCell {
    override class var reuseIdentifier: String { return "FileUploadQuestionCell" }
    // TODO
}

class DateQuestionCell: QuestionCell {
    override class var reuseIdentifier: String { return "DateQuestionCell" }
    // TODO
}

class TimeQuestionCell: QuestionCell {
    override class var reuseIdentifier: String { return "TimeQuestionCell" }
    // TODO
}

class DateTimeQuestionCell: QuestionCell {
    override class var reuseIdentifier: String { return "DateTimeQuestionCell" }
    // TODO
}

class CountryCodeQuestionCell: QuestionCell {
    override class var reuseIdentifier: String { return "CountryCodeQuestionCell" }
    // TODO
}
