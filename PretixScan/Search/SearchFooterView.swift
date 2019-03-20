//
//  SearchFooterView.swift
//  PretixScan
//
//  Created by Daniel Jilg on 20.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class SearchFooterView: UIView {
    enum Status {
        case notEnoughCharacters
        case loading
        case searchCompleted(results: Int)
    }

    var status: Status = .notEnoughCharacters { didSet { updateStatus() } }
    private let label: UILabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }

    private func configureView() {
        label.textAlignment = .center
        label.textColor = UIColor.gray
        label.numberOfLines = 0
        addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        label.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        label.bottomAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: self.bottomAnchor, multiplier: 1)
        label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
    }

    private func updateStatus() {
        switch status {
        case .notEnoughCharacters:
            label.text = "Search will begin after you have typed at least 3 characters."
        case .loading:
            label.text = "Loading Search"
        case let .searchCompleted(results):
            label.text = "Found \(results) results"
        }
    }
}
