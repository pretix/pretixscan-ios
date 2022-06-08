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
    var exitMode: Bool {
        configStore?.scanMode == "exit"
    }
    
    /// If true, don't fire of any more requests
    private var beganRedeeming = false
    private var error: Error? { didSet { update() } }
    
    struct Configuration {
        let secret: String
        var force: Bool
        var ignoreUnpaid: Bool
        var answers: [Answer]?
    }
    
    private let presentationTime: TimeInterval = 5
    @IBOutlet private weak var backgroundColorView: UIView!
    @IBOutlet private weak var iconLabel: UILabel!
    @IBOutlet private weak var ticketStatusLabel: UILabel!
    @IBOutlet private weak var productNameLabel: UILabel!
    @IBOutlet private weak var attendeeNameLabel: UILabel!
    @IBOutlet private weak var orderIDLabel: UILabel!
    @IBOutlet private weak var extraInformationLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var blinkerView: BlinkerView!
    
    @IBOutlet var checkInUnpaidButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var checkInUnpaidButton: UIButton!
    
    // MARK: - Updating
    private func update() {
        DispatchQueue.main.async {
            guard self.isViewLoaded else { return }
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
        
        let newBackgroundColor = PXColor.error
        iconLabel.text = Icon.error
        ticketStatusLabel.text = Localization.TicketStatusViewController.Error
        toggleExtraInformationIfAvailable(.unknown)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
            self.backgroundColorView.backgroundColor = newBackgroundColor
            self.view.layoutIfNeeded()
        })
    }
    
    private func updateMain() {
        self.view.clipsToBounds = true
        self.activityIndicator.stopAnimating()
        
        iconLabel.isHidden = false
        setCheckInUnpaid(visible: false)
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
        
        let needsAttention = redemptionResponse.isRequireAttention
        let productName = redemptionResponse.position?.item?.name.representation(in: Locale.current) ?? ""
        
        productNameLabel.text = productName
        if let variationName = redemptionResponse.position?.calculatedVariation?.name.representation(in: Locale.current) {
            productNameLabel.text = (productNameLabel.text ?? "") + " – \(variationName)"
        }
        
        attendeeNameLabel.text = redemptionResponse.position?.attendeeName
        orderIDLabel.text =
        "\(redemptionResponse.position?.orderCode ?? "") \(redemptionResponse.position?.order?.status.localizedDescription() ?? "")"
        
        var newBackgroundColor = PXColor.grayBackground
        blinkerView.isHidden = true
        
        switch redemptionResponse.status {
        case .redeemed:
            newBackgroundColor = PXColor.okay
            updateToRedeemed(needsAttention: needsAttention, redemptionResponse.position?.seat, exitMode)
        case .incomplete:
            newBackgroundColor = PXColor.warning
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
        backgroundColorView.backgroundColor = PXColor.grayBackground
        iconLabel.text = Icon.general
        ticketStatusLabel.text = nil
        productNameLabel.text = nil
        attendeeNameLabel.text = nil
        orderIDLabel.text = nil
        extraInformationLabel.text = nil
        extraInformationLabel.attributedText = nil
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
                answers: configuration.answers,
                as: self.configStore?.scanMode ?? "entry"
            ) { (redemptionResponse, error) in
                DispatchQueue.main.async {[weak self] in
                    self?.error = error
                    self?.redemptionResponse = redemptionResponse
                    
                    // Announce feedback if needed
                    if self?.configuration?.ignoreUnpaid == true {
                        return
                    }
                    self?.configStore?.feedbackGenerator.announce(redemptionResponse: redemptionResponse, error, self?.exitMode == true)
                }
                
                // Dismiss
                if redemptionResponse?.status != .incomplete {
                    DispatchQueue.main.asyncAfter(deadline: .now() + self.presentationTime) {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    private func updateToRedeemed(needsAttention: Bool, _ seat: Seat?, _ exitMode: Bool) {
        if (exitMode) {
            iconLabel.text = Icon.exit
            setTicketStatus(status: Localization.TicketStatusViewController.ValidExit, with: seat)
        } else {
            iconLabel.text = Icon.okay
            setTicketStatus(status: Localization.TicketStatusViewController.ValidTicket, with: seat)
        }
        
        if needsAttention {
            blinkerView.isHidden = false
            if (exitMode) {
                setTicketStatus(status: Localization.TicketStatusViewController.ValidExit, with: seat)
            } else {
                setTicketStatus(status: Localization.TicketStatusViewController.ValidTicket, with: seat)
            }
            iconLabel.text = Icon.attention
        }
    }
    
    private func setTicketStatus(status: String, with seat: Seat?) {
        if let seatName = seat?.name, seatName != "" {
            ticketStatusLabel.text = "\(status)\n\(seatName)"
        } else {
            ticketStatusLabel.text = status
        }
    }
    
    private func updateToIncomplete(_ redemptionResponse: RedemptionResponse) {
        let questionsController = createQuestionsController()
        let questions = redemptionResponse.questions ?? []
        questionsController.questions = questions
        
        if let answers = redemptionResponse.answers {
            var mappedAnswers = [Answer?](repeating: nil, count: questions.count)
            for (index, question) in questions.enumerated() {
                if let answer = answers.filter({ $0.question == question.identifier }).first {
                    mappedAnswers[index] = answer
                }
            }
            questionsController.answers = mappedAnswers
        }
        
        let navigationController = UINavigationController(rootViewController: questionsController)
        navigationController.navigationBar.prefersLargeTitles = true
        present(navigationController, animated: true, completion: nil)
    }
    
    private func updateToError(_ redemptionResponse: RedemptionResponse) -> UIColor {
        var newBackgroundColor = UIColor.blue
        if redemptionResponse.errorReason == .alreadyRedeemed {
            newBackgroundColor = PXColor.warning
            iconLabel.text = Icon.warning
            setTicketStatus(status: Localization.TicketStatusViewController.TicketAlreadyRedeemed, with: redemptionResponse.position?.seat)
            
            if let lastCheckIn = redemptionResponse.lastCheckIn {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .medium
                ticketStatusLabel.text = (ticketStatusLabel.text ?? "") + "\n\(dateFormatter.string(from: lastCheckIn.date))"
            }
        } else {
            newBackgroundColor = PXColor.error
            iconLabel.text = Icon.error
            setTicketStatus(status: Localization.TicketStatusViewController.InvalidTicket, with: redemptionResponse.position?.seat)
            productNameLabel.text = redemptionResponse.localizedErrorReason
            
            if redemptionResponse.errorReason == .unpaid && configStore?.checkInList?.includePending == true {
                setCheckInUnpaid(visible: true)
            }
        }
        
        toggleExtraInformationIfAvailable(redemptionResponse._validationReason)
        
        return newBackgroundColor
    }
    
    private func toggleExtraInformationIfAvailable(_ reason: TicketValidationReason) {
        let extraInformation: TicketStatusExtraInformation = configStore?.ticketValidator?.isOnline == false ? .offlineValidation : .none
        updateExtraInformation(extraInformation, reason)
    }
    
    private func updateExtraInformation(_ extra: TicketStatusExtraInformation, _ reason: TicketValidationReason) {
        switch extra {
        case .offlineValidation:
            let attachment = NSTextAttachment()
            attachment.image = UIImage(systemName: "wifi.slash")?.withRenderingMode(.alwaysTemplate)
            let imageString = NSMutableAttributedString(attachment: attachment)
            imageString.append(NSAttributedString(string: " "))
            let textString = NSAttributedString(string: Localization.TicketStatusViewController.OfflineValidation)
            imageString.append(textString)
            if reason != .unknown {
                imageString.append(NSAttributedString(string: " (\(reason.rawValue))"))
            }
            extraInformationLabel.attributedText = imageString
            extraInformationLabel.sizeToFit()
            
        case .none:
            extraInformationLabel.text = nil
        }
    }
    
    private func createQuestionsController() -> QuestionsTableViewController {
        let questionsController = QuestionsTableViewController(style: .plain)
        questionsController.configStore = configStore
        questionsController.delegate = self
        return questionsController
    }
    
    /// Configures the view to show or hide the check in unpaid button
    private func setCheckInUnpaid(visible: Bool) {
        checkInUnpaidButton.isHidden = !visible
        // we need to move the content of the message up to make room for the checkInUnpaidButton
        if visible {
            checkInUnpaidButtonBottomConstraint.constant = 90
        } else {
            checkInUnpaidButtonBottomConstraint.constant = 20
        }
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
        checkInUnpaidButton.setTitle(Localization.TicketStatusViewController.UnpaidContinueButtonTitle, for: . normal)
        update()
    }
    
    @IBAction func tap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension TicketStatusViewController: QuestionsTableViewControllerDelegate {
    func receivedAnswers(_ answers: [Answer]) {
        redemptionResponse = nil
        beganRedeeming = false
        configuration?.answers = answers
    }
    
    func cancelAnsweringCheckInQuestions() {
        dismiss(animated: true)
    }
}
