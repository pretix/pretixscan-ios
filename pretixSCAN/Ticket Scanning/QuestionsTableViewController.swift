//
//  QuestionsTableViewController.swift
//  pretixSCAN
//
//  Created by Daniel Jilg on 15.07.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class QuestionsTableViewController: UITableViewController, Configurable {
    // MARK: Properties
    var configStore: ConfigStore?
    var questions = [Question]()

    override func viewDidLoad() {
        super.viewDidLoad()

        for cellType in [
            NumberQuestionCell.self, OneLineStringQuestionCell.self, MultiLineStringQuestionCell.self, BoolQuestionCell.self,
            SingleChoiceQuestionCell.self, MultipleChoiceQuestionCell.self, FileUploadQuestionCell.self, DateQuestionCell.self,
            TimeQuestionCell.self, DateTimeQuestionCell.self, CountryCodeQuestionCell.self
        ] {
            tableView.register(cellType, forCellReuseIdentifier: cellType.reuseIdentifier)
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cell(for: questions[indexPath.row], indexPath: indexPath)
    }

    // swiftlint:disable force_cast
    // swiftlint:disable cyclomatic_complexity
    private func cell(for question: Question, indexPath: IndexPath) -> QuestionCell {
        var returnCell: QuestionCell

        switch question.type {
        case .number:
            let cell = tableView.dequeueReusableCell(withIdentifier: NumberQuestionCell.reuseIdentifier, for: indexPath)
            returnCell = cell as! NumberQuestionCell
        case .oneLineString:
            let cell = tableView.dequeueReusableCell(withIdentifier: OneLineStringQuestionCell.reuseIdentifier, for: indexPath)
            returnCell = cell as! OneLineStringQuestionCell
        case .multiLineString:
            let cell = tableView.dequeueReusableCell(withIdentifier: MultiLineStringQuestionCell.reuseIdentifier, for: indexPath)
            returnCell = cell as! MultiLineStringQuestionCell
        case .boolean:
            let cell = tableView.dequeueReusableCell(withIdentifier: BoolQuestionCell.reuseIdentifier, for: indexPath)
            returnCell = cell as! BoolQuestionCell
        case .choiceFromList:
            let cell = tableView.dequeueReusableCell(withIdentifier: SingleChoiceQuestionCell.reuseIdentifier, for: indexPath)
            returnCell = cell as! SingleChoiceQuestionCell
        case .multipleChoiceFromList:
            let cell = tableView.dequeueReusableCell(withIdentifier: MultipleChoiceQuestionCell.reuseIdentifier, for: indexPath)
            returnCell = cell as! MultipleChoiceQuestionCell
        case .fileUpload:
            let cell = tableView.dequeueReusableCell(withIdentifier: FileUploadQuestionCell.reuseIdentifier, for: indexPath)
            returnCell = cell as! FileUploadQuestionCell
        case .date:
            let cell = tableView.dequeueReusableCell(withIdentifier: DateQuestionCell.reuseIdentifier, for: indexPath)
            returnCell = cell as! DateQuestionCell
        case .time:
            let cell = tableView.dequeueReusableCell(withIdentifier: TimeQuestionCell.reuseIdentifier, for: indexPath)
            returnCell = cell as! TimeQuestionCell
        case .dateAndTime:
            let cell = tableView.dequeueReusableCell(withIdentifier: DateTimeQuestionCell.reuseIdentifier, for: indexPath)
            returnCell = cell as! DateTimeQuestionCell
        case .countryCode:
            let cell = tableView.dequeueReusableCell(withIdentifier: CountryCodeQuestionCell.reuseIdentifier, for: indexPath)
            returnCell = cell as! CountryCodeQuestionCell
        }

        returnCell.question = question
        return returnCell
    }
}
