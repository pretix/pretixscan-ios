//
//  TicketStatusViewController.swift
//  PretixScan
//
//  Created by Daniel Jilg on 25.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class TicketStatusViewController: UIViewController, Configurable, AppCoordinatorReceiver {
    var appCoordinator: AppCoordinator?
    var configStore: ConfigStore?
    var configuration: Configuration? { didSet { update() } }
    var redemptionResponse: RedemptionResponse? { didSet { update() } }

    /// If true, don't fire of any more requests
    private var beganRedeeming = false
    private var error: Error? { didSet { update() } }

    struct Configuration {
        let secret: String
        var force: Bool
        var ignoreUnpaid: Bool
        var answers: [String: String]?
    }

    private let presentationTime: TimeInterval = 5
    @IBOutlet private weak var backgroundColorView: UIView!
    @IBOutlet private weak var iconLabel: UILabel!
    @IBOutlet private weak var ticketStatusLabel: UILabel!
    @IBOutlet private weak var productNameLabel: UILabel!
    @IBOutlet private weak var attendeeNameLabel: UILabel!
    @IBOutlet private weak var orderIDLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var blinkerView: BlinkerView!

    @IBOutlet weak var unpaidNoticeContainerView: UIView!
    @IBOutlet weak var unpaidNoticeLabel: UILabel!
    @IBOutlet weak var unpaidNoticeButton: UIButton!
    @IBOutlet weak var unpaidNoticeCancelButton: UIButton!

    // MARK: - Updating
    private func update() {
        guard isViewLoaded else { return }
        DispatchQueue.main.async {
            self.updateMain()
        }
    }

    fileprivate func showError() {
        resetToEmpty()

        productNameLabel.text = Localization.TicketStatusViewController.InvalidTicket

        if let apiError = error as? APIError {
            switch apiError {
            case .notFound:
                orderIDLabel.text = Localization.Errors.TicketNotFound
            default:
                orderIDLabel.text = self.error?.localized
            }
        }

        let newBackgroundColor = Color.error
        iconLabel.text = Icon.error
        ticketStatusLabel.text = Localization.TicketStatusViewController.Error
        appCoordinator?.performHapticNotification(ofType: .error)

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
            self.backgroundColorView.backgroundColor = newBackgroundColor
            self.view.layoutIfNeeded()
        })
    }

    private func updateMain() {
        self.view.clipsToBounds = true
        self.activityIndicator.stopAnimating()

        unpaidNoticeContainerView.isHidden = true
        unpaidNoticeContainerView.layer.cornerRadius = Style.cornerRadius
        unpaidNoticeLabel.text = Localization.TicketStatusViewController.UnpaidContinueText
        unpaidNoticeButton.setTitle(Localization.TicketStatusViewController.UnpaidContinueButtonTitle, for: . normal)
        unpaidNoticeCancelButton.setTitle(Localization.TicketStatusViewController.UnpaidCancelButtonTitle, for: . normal)

        if configuration != nil, redemptionResponse == nil, beganRedeeming == false {
            redeem()
        }

        guard error == nil else {
            showError()
            return
        }

        guard let redemptionResponse = self.redemptionResponse else {
            resetToEmpty()
            return
        }

        let needsAttention = (redemptionResponse.position?.order?.checkInAttention == true)
            || (redemptionResponse.position?.item?.checkInAttention == true)

        productNameLabel.text = "\(redemptionResponse.position?.item?.name.representation(in: Locale.current) ?? "🎟")"
        if let variationName = redemptionResponse.position?.calculatedVariation?.name.representation(in: Locale.current) {
            productNameLabel.text = (productNameLabel.text ?? "") + " – \(variationName)"
        }

        attendeeNameLabel.text = redemptionResponse.position?.attendeeName
        orderIDLabel.text =
        "\(redemptionResponse.position?.orderCode ?? "") \(redemptionResponse.position?.order?.status.localizedDescription() ?? "")"

        var newBackgroundColor = Color.grayBackground
        blinkerView.isHidden = true

        switch redemptionResponse.status {
        case .redeemed:
            newBackgroundColor = Color.okay
            updateToRedeemed(needsAttention: needsAttention)

        case .incomplete:
            newBackgroundColor = Color.warning
            updateToIncomplete(redemptionResponse)
            return

        case .error:
            newBackgroundColor = updateToError(redemptionResponse)
        }

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
            self.backgroundColorView.backgroundColor = newBackgroundColor
            self.view.layoutIfNeeded()
        })
    }

    private func resetToEmpty() {
        backgroundColorView.backgroundColor = Color.grayBackground
        iconLabel.text = Icon.general
        ticketStatusLabel.text = nil
        productNameLabel.text = nil
        attendeeNameLabel.text = nil
        orderIDLabel.text = nil
    }

    private func redeem() {
        beganRedeeming = true
        guard let configuration = configuration else { return }

        activityIndicator.startAnimating()

        // The wait here fixes a timing issue with presentation animations
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.configStore?.ticketValidator?.redeem(
                secret: configuration.secret,
                force: configuration.force,
                ignoreUnpaid: configuration.ignoreUnpaid,
                answers: configuration.answers
            ) { (redemptionResponse, error) in
                self.error = error
                self.redemptionResponse = redemptionResponse

                // Dismiss
                if redemptionResponse?.status != .incomplete {
                    DispatchQueue.main.asyncAfter(deadline: .now() + self.presentationTime) {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }

    private func updateToRedeemed(needsAttention: Bool) {
        iconLabel.text = Icon.okay
        ticketStatusLabel.text = Localization.TicketStatusViewController.ValidTicket
        appCoordinator?.performHapticNotification(ofType: .success)

        if needsAttention {
            blinkerView.isHidden = false
            ticketStatusLabel.text = Localization.TicketStatusViewController.ValidTicket
            iconLabel.text = Icon.attention
            appCoordinator?.performHapticNotification(ofType: .warning)
        }
    }

    private func updateToIncomplete(_ redemptionResponse: RedemptionResponse) {
        let questionsController = createQuestionsController()
        questionsController.questions = redemptionResponse.questions ?? []
        let navigationController = UINavigationController(rootViewController: questionsController)
        navigationController.navigationBar.prefersLargeTitles = true
        present(navigationController, animated: true, completion: nil)
    }

    private func updateToError(_ redemptionResponse: RedemptionResponse) -> UIColor {
        var newBackgroundColor = UIColor.blue
        if redemptionResponse.errorReason == .alreadyRedeemed {
            newBackgroundColor = Color.warning
            iconLabel.text = Icon.warning
            ticketStatusLabel.text = Localization.TicketStatusViewController.TicketAlreadyRedeemed
            appCoordinator?.performHapticNotification(ofType: .warning)

            if let lastCheckIn = redemptionResponse.lastCheckIn {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .medium
                ticketStatusLabel.text = (ticketStatusLabel.text ?? "") + "\n\(dateFormatter.string(from: lastCheckIn.date))"
            }
        } else {
            newBackgroundColor = Color.error
            iconLabel.text = Icon.error
            ticketStatusLabel.text = Localization.TicketStatusViewController.InvalidTicket
            productNameLabel.text = redemptionResponse.errorReason?.localizedDescription()
            appCoordinator?.performHapticNotification(ofType: .error)

            if redemptionResponse.errorReason == .unpaid && configStore?.checkInList?.includePending == true {
                unpaidNoticeContainerView.isHidden = false
            }
        }

        return newBackgroundColor
    }

    private func createQuestionsController() -> QuestionsTableViewController {
        let questionsController = QuestionsTableViewController(style: .plain)
        questionsController.configStore = configStore
        questionsController.delegate = self
        return questionsController
    }

    // MARK: - Actions
    @IBAction func redeemUnpaidTicket(_ sender: Any) {
        guard let configuration = configuration else { return }
        self.dismiss(animated: true, completion: nil)
        appCoordinator?.redeem(secret: configuration.secret, force: configuration.force, ignoreUnpaid: true)
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        preferredContentSize = CGSize(width: 0, height: UIScreen.main.bounds.height * 0.50)
        update()
    }

    @IBAction func tap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension TicketStatusViewController: QuestionsTableViewControllerDelegate {
    func receivedAnswers(_ answers: [Answer]) {
        var answerDict = [String: String]()
        for answer in answers {
            answerDict["\(answer.question)"] = answer.answer
        }
        redemptionResponse = nil
        beganRedeeming = false
        configuration?.answers = answerDict
    }
}
