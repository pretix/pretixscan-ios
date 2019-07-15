//
//  QuestionCell.swift
//  pretixSCAN
//
//  Created by Daniel Jilg on 15.07.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

protocol QuestionCellDelegate: class {
    func update(answer: Answer)
}

class QuestionCell: UITableViewCell {
    // MARK: Properties
    class var reuseIdentifier: String { return "QuestionCell" }

    var question: Question? { didSet { update() }}
    weak var delegate: QuestionCellDelegate?

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
            let allowEdit = updatedText.count <= 14

            if let question = question, allowEdit {
                let answer = Answer(question: question.identifier, answer: updatedText, questionStringIdentifier: nil,
                                options: [], optionStringIdentifiers: [])
                delegate?.update(answer: answer)
            }
            return allowEdit

        } else {
            return false
        }
    }
}

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
            delegate?.update(answer: Answer(question: question.identifier, answer: textFieldText, questionStringIdentifier: nil,
                                            options: [], optionStringIdentifiers: []))
        }
        return true
    }
}

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
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let question = question, let textFieldText = textView.text {
            delegate?.update(answer: Answer(question: question.identifier, answer: textFieldText, questionStringIdentifier: nil,
                                            options: [], optionStringIdentifiers: []))
        }

        return true
    }
}

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
            delegate?.update(answer: Answer(question: question.identifier, answer: onButton.isSelected ? "true" : "false",
                                            questionStringIdentifier: nil, options: [], optionStringIdentifiers: []))
        }
    }
}

class SingleChoiceQuestionCell: QuestionCell {
    override class var reuseIdentifier: String { return "SingleChoiceQuestionCell" }

    var buttons: [ChoiceButton] = []

    let secondaryStackView: UIStackView = {
        let secondaryStackView = UIStackView()
        secondaryStackView.axis = .vertical
        secondaryStackView.distribution = UIStackView.Distribution.fillProportionally
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
            delegate?.update(answer: Answer(question: question.identifier, answer: "\(sender.tag)",
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

            delegate?.update(answer: Answer(question: question.identifier, answer: allTags,
                questionStringIdentifier: nil, options: [], optionStringIdentifiers: []))
        }
    }
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
