//
//  CheckInStatusLargerOverviewCell.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 20/09/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import UIKit

class CheckInStatusLargerOverviewCell: UITableViewCell {
    static let reuseIdentifier = "largerOverviewCell"

    @IBOutlet private weak var checkInCountLabel: UILabel!
    @IBOutlet private weak var positionCountLabel: UILabel!
    @IBOutlet private weak var checkInCountTitleLabel: UILabel!
    @IBOutlet private weak var positionCountTitleLabel: UILabel!
    
    @IBOutlet private weak var totalInsideLabel: UILabel!
    @IBOutlet private weak var totalInsideTitleLabel: UILabel!

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
        totalInsideTitleLabel.text = Localization.CheckInStatusOverviewTableViewCell.InsideCountTitle

        guard let checkInListStatus = checkInListStatus else {
            checkInCountLabel.text = "–"
            positionCountLabel.text = "–"
            totalInsideLabel.text = "–"
            return
        }

        checkInCountLabel.text = numberFormatter.string(from: NSNumber(value: checkInListStatus.checkinCount))
        positionCountLabel.text = numberFormatter.string(from: NSNumber(value: checkInListStatus.positionCount))
        totalInsideLabel.text = numberFormatter.string(from: NSNumber(value: checkInListStatus.insideCount))
    }
}
