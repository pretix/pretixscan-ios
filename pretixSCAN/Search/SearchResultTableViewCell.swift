//
//  SearchResultTableViewCell.swift
//  PretixScan
//
//  Created by Daniel Jilg on 20.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {
    var orderPosition: OrderPosition? { didSet { configure() }}
    var checkInList: CheckInList? { didSet { configure() }}
    var event: Event? { didSet { configure() }}

    @IBOutlet private weak var orderCodeLabel: UILabel!
    @IBOutlet private weak var orderIDLabel: UILabel!
    @IBOutlet private weak var ticketType: UILabel!
    @IBOutlet private weak var secretLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var statusBackgroundView: UIView!

    private func configure() {
        guard
            let event = event,
            let checkInList = checkInList,
            let orderPosition = orderPosition
        else {
            orderCodeLabel.text = "--"
            ticketType.text = nil
            statusLabel.text = nil
            secretLabel.text = nil
            return
        }

        orderCodeLabel.text = "\(orderPosition.attendeeName ?? "--")"
        orderIDLabel.text = orderPosition.orderCode
        ticketType.text = orderPosition.item?.name.representation(in: Locale.current) ?? "\(orderPosition.itemIdentifier)"

        if let variationName = orderPosition.calculatedVariation?.name.representation(in: Locale.current) {
            ticketType.text = (ticketType.text ?? "") + " – \(variationName)"
        }

        secretLabel.text = orderPosition.secret

        guard let redemptionResponse = orderPosition.createRedemptionResponse(force: false, ignoreUnpaid: false,
                                                                              in: event, in: checkInList) else {
            statusBackgroundView.backgroundColor = Color.error
            statusLabel.text = Localization.TicketStatusViewController.InvalidTicket
            return
        }

        if redemptionResponse.status == .redeemed {
            statusBackgroundView.backgroundColor = Color.okay
            statusLabel.text = Localization.TicketStatusViewController.ValidTicket
        } else if redemptionResponse.errorReason == .alreadyRedeemed {
            statusBackgroundView.backgroundColor = Color.warning
            statusLabel.text = Localization.TicketStatusViewController.TicketAlreadyRedeemed
        } else if redemptionResponse.errorReason == .unpaid && checkInList.includePending {
            statusBackgroundView.backgroundColor = Color.okay
            statusLabel.text = redemptionResponse.errorReason?.localizedDescription()
        } else {
            statusBackgroundView.backgroundColor = Color.error
            statusLabel.text = redemptionResponse.errorReason?.localizedDescription()
        }

    }
}
