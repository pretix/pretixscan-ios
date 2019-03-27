//
//  AdvancedCheckInStatusItemTableViewCell.swift
//  PretixScan
//
//  Created by Daniel Jilg on 27.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class AdvancedCheckInStatusItemTableViewCell: UITableViewCell {

    @IBOutlet private weak var itemNameLabel: UILabel!
    @IBOutlet private weak var itemCountLabel: UILabel!

    var checkInListStatusItem: CheckInListStatus.Item? { didSet { update() }}

    private let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = "\u{2008}"
        return numberFormatter
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        update()
    }

    private func update() {
        itemCountLabel.text = "–/–"
        guard let checkInListStatusItem = checkInListStatusItem else {
            itemNameLabel.text = "-"
            return
        }

        itemNameLabel.text = checkInListStatusItem.name

        if let checkInCount = numberFormatter.string(from: NSNumber(value: checkInListStatusItem.checkinCount)),
            let positionCount = numberFormatter.string(from: NSNumber(value: checkInListStatusItem.positionCount)) {
            itemCountLabel.text = "\(checkInCount)/\(positionCount)"
        }
    }
}
