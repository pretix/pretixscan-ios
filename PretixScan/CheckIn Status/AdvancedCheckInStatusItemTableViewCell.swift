//
//  AdvancedCheckInStatusItemTableViewCell.swift
//  PretixScan
//
//  Created by Daniel Jilg on 27.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class AdvancedCheckInStatusItemTableViewCell: UITableViewCell {

    static let reuseIdentifier = "advancedStatusItemCell"

    @IBOutlet private weak var itemNameLabel: UILabel!
    @IBOutlet private weak var itemCountLabel: UILabel!
    @IBOutlet weak var variantsTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var variantsTableView: UITableView!

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
        variantsTableViewHeightConstraint.constant = CGFloat((checkInListStatusItem.variations?.count ?? 0) * 44)

        if let checkInCount = numberFormatter.string(from: NSNumber(value: checkInListStatusItem.checkinCount)),
            let positionCount = numberFormatter.string(from: NSNumber(value: checkInListStatusItem.positionCount)) {
            itemCountLabel.text = "\(checkInCount)/\(positionCount)"
        }
    }
}

extension AdvancedCheckInStatusItemTableViewCell: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checkInListStatusItem?.variations?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ItemVariationTableViewCell.reuseIdentifier, for: indexPath)
        if let cell = cell as? ItemVariationTableViewCell {
            cell.itemVariation = checkInListStatusItem?.variations?[indexPath.row]
        }
        return cell
    }

}
