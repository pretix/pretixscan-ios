//
//  SearchResultTableViewCell.swift
//  PretixScan
//
//  Created by Daniel Jilg on 20.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {
    var searchResult: SearchResult? { didSet { configure() }}
    @IBOutlet private weak var orderCodeLabel: UILabel!
    @IBOutlet private weak var orderIDLabel: UILabel!
    @IBOutlet private weak var ticketType: UILabel!
    @IBOutlet private weak var secretLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var statusBackgroundView: UIView!

    private func configure() {
        guard
            let searchResult = searchResult
        else {
            orderCodeLabel.text = "--"
            ticketType.text = nil
            statusLabel.text = nil
            secretLabel.text = nil
            return
        }

        orderCodeLabel.text = "\(searchResult.orderCode ?? "--")"
        orderIDLabel.text = searchResult.positionId != nil ? "\(searchResult.positionId!)" : ""
        ticketType.text = searchResult.ticket ?? "--"

        if let variation = searchResult.variation {
            ticketType.text = (ticketType.text ?? "") + " – \(variation)"
        }

        secretLabel.text = searchResult.secret ?? "--"
        
        if searchResult.isRedeemed {
            statusBackgroundView.backgroundColor = PXColor.warning
            statusLabel.text = Localization.TicketStatusViewController.Redeemed
        } else {
            switch searchResult.status! {
            case .paid:
                statusBackgroundView.backgroundColor = PXColor.okay
                statusLabel.text = Localization.TicketStatusViewController.Valid
            case .cancelled:
                statusBackgroundView.backgroundColor = PXColor.error
                statusLabel.text = Localization.TicketStatusViewController.CanceledTicket
            case .pending:
                statusBackgroundView.backgroundColor = PXColor.error
                statusLabel.text = Localization.TicketStatusViewController.UnpaidTicket
            }
        }
    }
}
