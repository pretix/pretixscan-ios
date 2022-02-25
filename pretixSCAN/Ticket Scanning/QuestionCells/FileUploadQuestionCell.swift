//
//  FileUploadQuestionCell.swift
//  pretixSCAN
//
//  Created by Daniel Jilg on 13.08.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class FileUploadQuestionCell: QuestionCell {
    override class var reuseIdentifier: String { return "FileUploadQuestionCell" }
    let noticeLabel: UILabel = {
        let noticeLabel = UILabel()
        noticeLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        noticeLabel.textColor = PXColor.secondary
        noticeLabel.numberOfLines = 0
        return noticeLabel
    }()

    override func setup() {
        super.setup()
        noticeLabel.text = Localization.QuestionsTableViewController.UploadNotPossibleNotice
        mainStackView.addArrangedSubview(noticeLabel)
    }
}
