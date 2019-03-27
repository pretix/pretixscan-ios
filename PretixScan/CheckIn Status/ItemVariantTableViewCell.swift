//
//  ItemVariantTableViewCell.swift
//  PretixScan
//
//  Created by Daniel Jilg on 27.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class ItemVariantTableViewCell: UITableViewCell {
    static let reuseIdentifier = "itemVariantCell"

    var itemVariation: CheckInListStatus.Item.Variation? { didSet { update() }}

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var countLabel: UILabel!

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
        nameLabel.text = itemVariation?.value

        if let itemVariation = itemVariation,
            let checkInCount = numberFormatter.string(from: NSNumber(value: itemVariation.checkinCount)),
            let positionCount = numberFormatter.string(from: NSNumber(value: itemVariation.positionCount)) {
            countLabel.text = "\(checkInCount)/\(positionCount)"
        } else {
            countLabel.text = nil
        }
    }
}
