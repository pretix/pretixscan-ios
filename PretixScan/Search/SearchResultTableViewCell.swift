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

    @IBOutlet private weak var orderCodeLabel: UILabel!
    @IBOutlet private weak var orderIDLabel: UILabel!
    @IBOutlet private weak var ticketType: UILabel!
    @IBOutlet private weak var secretLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var statusBackgroundView: UIView!

    private func configure() {
        guard let orderPosition = orderPosition else {
            orderCodeLabel.text = "--"
            ticketType.text = nil
            statusLabel.text = nil
            secretLabel.text = nil
            return
        }

        orderCodeLabel.text = "\(orderPosition.attendeeName ?? "--")"
        orderIDLabel.text = orderPosition.order
        ticketType.text = "\(orderPosition.item?.name.description ?? "\(orderPosition.itemIdentifier)")"
        secretLabel.text = orderPosition.secret
        statusLabel.text = orderPosition.checkins.count > 0 ?
            Localization.SearchResultsTableViewCell.Redeemed : Localization.SearchResultsTableViewCell.Valid
        statusBackgroundView.backgroundColor = orderPosition.checkins.count > 0 ? Color.warning : Color.okay
    }
}
