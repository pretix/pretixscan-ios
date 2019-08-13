//
//  QuestionsTableViewController.swift
//  pretixSCAN
//
//  Created by Daniel Jilg on 15.07.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

protocol QuestionsTableViewControllerDelegate: class {
    func receivedAnswers(_ answers: [Answer])
}

class QuestionsTableViewController: UITableViewController, Configurable, QuestionCellDelegate {
    // MARK: Properties
    var configStore: ConfigStore?
    var questions = [Question]() { didSet { answers = [Answer?](repeating: nil, count: questions.count) }}

    weak var delegate: QuestionsTableViewControllerDelegate?

    private var answers = [Answer?]()
    private var indexPathForAttention: IndexPath?
    private var lastCellForAttention: QuestionCell?
    private var doneButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = false

        title = Localization.QuestionsTableViewController.Title
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveAndExit))
        navigationItem.rightBarButtonItem = doneButton

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
        return cell(for: questions[indexPath.row], answer: answers[indexPath.row], indexPath: indexPath)
    }

    // swiftlint:disable force_cast
    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable function_body_length
    private func cell(for question: Question, answer: Answer?, indexPath: IndexPath) -> QuestionCell {
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

        returnCell.delegate = self
        returnCell.indexPath = indexPath
        returnCell.question = question
        returnCell.answer = answer
        returnCell.shouldStandOut = indexPath == indexPathForAttention

        return returnCell
    }

    // MARK: - Question Cell Delegate
    func answerUpdated(for indexPath: IndexPath?, newAnswer: Answer?) {
        guard let indexPath = indexPath else { return }
        answers[indexPath.row] = newAnswer
    }

    // MARK: - Saving
    @objc
    func saveAndExit() {
        indexPathForAttention = nil
        lastCellForAttention?.shouldStandOut = false
        lastCellForAttention = nil

        // Check if all mandatory questions are filled out
        for (question, answer) in zip(questions, answers) {
            if question.isRequired && answer == nil {
                missingAnswer(for: question)
                return
            }
        }

        // Collate Questions and Return them
        let answerList = answers.compactMap({$0})
        self.delegate?.receivedAnswers(answerList)

        // Bye bye
        dismiss(animated: true)
    }

    private func missingAnswer(for question: Question) {
        guard let indexOfQuestion = questions.firstIndex(of: question) else { return }
        let indexPathForQuestion = IndexPath(row: indexOfQuestion, section: 0)
        indexPathForAttention = indexPathForQuestion

        if tableView.indexPathsForVisibleRows?.contains(indexPathForQuestion) == true {
            lastCellForAttention = tableView.cellForRow(at: indexPathForQuestion) as? QuestionCell
            lastCellForAttention?.shouldStandOut = true
        }

        tableView.scrollToRow(at: indexPathForQuestion, at: .top, animated: true)

    }
}
