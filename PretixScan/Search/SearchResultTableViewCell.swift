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
    @IBOutlet private weak var ticketType: UILabel!
    @IBOutlet weak var secretLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!

    private func configure() {
        guard let orderPosition = orderPosition else {
            orderCodeLabel.text = "--"
            ticketType.text = nil
            statusLabel.text = nil
            secretLabel.text = nil
            return
        }

        orderCodeLabel.text = "\(orderPosition.order) \(orderPosition.attendeeName ?? "--")"
        ticketType.text = "NO TYPE"
        secretLabel.text = orderPosition.secret
        statusLabel.text = "NO STATUS"
    }
}
