//
//  TicketStatusViewController.swift
//  PretixScan
//
//  Created by Daniel Jilg on 25.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class TicketStatusViewController: UIViewController {
    var redemptionResponse: RedemptionResponse? { didSet { update() }}

    private let presentationTime: TimeInterval = 5
    @IBOutlet private weak var backgroundColorView: UIView!
    @IBOutlet private weak var iconLabel: UILabel!
    @IBOutlet private weak var ticketStatusLabel: UILabel!
    @IBOutlet private weak var productNameLabel: UILabel!
    @IBOutlet private weak var attendeeNameLabel: UILabel!
    @IBOutlet private weak var orderIDLabel: UILabel!

    // MARK: - Updating
    private func update() {
        guard isViewLoaded else { return }

        guard let redemptionResponse = self.redemptionResponse else {
            backgroundColorView.backgroundColor = Color.primary
            iconLabel.text = Icon.general
            ticketStatusLabel.text = nil
            productNameLabel.text = nil
            attendeeNameLabel.text = nil
            orderIDLabel.text = nil
            return
        }

        productNameLabel.text = "\(redemptionResponse.position?.item ?? 0)"
        attendeeNameLabel.text = redemptionResponse.position?.attendeeName
        orderIDLabel.text = redemptionResponse.position?.order

        switch redemptionResponse.status {
        case .redeemed:
            backgroundColorView.backgroundColor = Color.okay
            iconLabel.text = Icon.okay
            ticketStatusLabel.text = Localization.TicketStatusViewController.ValidTicket
        case .incomplete:
            backgroundColorView.backgroundColor = Color.warning
            iconLabel.text = Icon.warning
            ticketStatusLabel.text = Localization.TicketStatusViewController.IncompleteInformation
        case .error:
            if redemptionResponse.errorReason == .alreadyRedeemed {
                backgroundColorView.backgroundColor = Color.warning
                iconLabel.text = Icon.warning
                ticketStatusLabel.text = Localization.TicketStatusViewController.TicketAlreadyRedeemed
            } else {
                backgroundColorView.backgroundColor = Color.error
                iconLabel.text = Icon.error
                ticketStatusLabel.text = Localization.TicketStatusViewController.InvalidTicket
                productNameLabel.text = redemptionResponse.errorReason.map { $0.rawValue }
            }

        }
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        preferredContentSize = CGSize(width: 0, height: UIScreen.main.bounds.height * 0.70)
        update()
    }

    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + presentationTime) {
            self.dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func tap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
