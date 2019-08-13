//
//  DateQuestionCell.swift
//  pretixSCAN
//
//  Created by Daniel Jilg on 13.08.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class DateQuestionCell: QuestionCell {
    override class var reuseIdentifier: String { return "DateQuestionCell" }

    let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePicker.Mode.date
        return datePicker
    }()

    override func setup() {
        super.setup()
        mainStackView.addArrangedSubview(datePicker)
        datePicker.addTarget(self, action: #selector(dateUpdated(sender:)), for: .valueChanged)
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
