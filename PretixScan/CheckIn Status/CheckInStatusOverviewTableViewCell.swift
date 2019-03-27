//
//  CheckInStatusOverviewTableViewCell.swift
//  PretixScan
//
//  Created by Daniel Jilg on 27.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class CheckInStatusOverviewTableViewCell: UITableViewCell {
    @IBOutlet private weak var checkInCountLabel: UILabel!
    @IBOutlet private weak var positionCountLabel: UILabel!
    @IBOutlet private weak var checkInCountTitleLabel: UILabel!
    @IBOutlet private weak var positionCountTitleLabel: UILabel!

    var checkInListStatus: CheckInListStatus? { didSet { update() }}

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
        checkInCountTitleLabel.text = Localization.CheckInStatusOverviewTableViewCell.CheckInCountTitle
        positionCountTitleLabel.text = Localization.CheckInStatusOverviewTableViewCell.PositionCountTitle

        guard let checkInListStatus = checkInListStatus else {
            checkInCountLabel.text = "–"
            positionCountLabel.text = "–"
            return
        }

        checkInCountLabel.text = numberFormatter.string(from: NSNumber(value: checkInListStatus.checkinCount))
        positionCountLabel.text = numberFormatter.string(from: NSNumber(value: checkInListStatus.positionCount))
    }
}
