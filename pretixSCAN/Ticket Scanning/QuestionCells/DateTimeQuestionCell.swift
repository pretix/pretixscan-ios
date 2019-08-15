//
//  DateTimeQuestionCell.swift
//  pretixSCAN
//
//  Created by Daniel Jilg on 13.08.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class DateTimeQuestionCell: QuestionCell {
    override class var reuseIdentifier: String { return "DateTimeQuestionCell" }

    let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePicker.Mode.dateAndTime
        return datePicker
    }()

    override var delegate: QuestionCellDelegate? { didSet { dateUpdated(sender: datePicker) }}

    override func setup() {
        super.setup()
        mainStackView.addArrangedSubview(datePicker)
        datePicker.addTarget(self, action: #selector(dateUpdated(sender:)), for: .valueChanged)
    }

    override func update() {
        super.update()

        guard let dateString = answer?.answer, let date = DateFormatter.iso8601.date(from: dateString) else { return }
        datePicker.date = date
    }

    @IBAction func dateUpdated(sender: UIDatePicker) {
        if let question = question {
            let dateString = DateFormatter.iso8601.string(from: sender.date)
            delegate?.answerUpdated(for: indexPath, newAnswer: Answer(question: question.identifier, answer: dateString,
                                                                      questionStringIdentifier: nil, options: [],
                                                                      optionStringIdentifiers: []))
        }
    }
}
