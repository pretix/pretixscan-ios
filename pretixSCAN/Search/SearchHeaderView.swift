//
//  SearchHeaderView.swift
//  PretixScan
//
//  Created by Daniel Jilg on 20.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class SearchHeaderView: UIView {
    enum Status {
        case notEnoughCharacters
        case loading
        case searchCompleted(results: Int)
    }

    var status: Status = .notEnoughCharacters { didSet { updateStatus() } }

    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.gray
        label.numberOfLines = 0
        return label
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = PXColor.primary
        return indicator
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }

    private func configureView() {
        backgroundColor = PXColor.grayBackground

        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        label.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor, constant: 10).isActive = true
        label.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: -10).isActive = true
        label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

        addSubview(loadingIndicator)
        loadingIndicator.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 18).isActive = true
        loadingIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

        let searchHeaderViewFrame = CGRect(x: 0, y: 0, width: frame.width, height: 72)
        frame = searchHeaderViewFrame
    }

    private func updateStatus() {
        switch status {
        case .notEnoughCharacters:
            label.text = Localization.SearchHeaderView.NotEnoughCharacters
            loadingIndicator.stopAnimating()
        case .loading:
            label.text = Localization.SearchHeaderView.Loading
            loadingIndicator.startAnimating()
        case let .searchCompleted(results):
            switch results {
            case 0:
                label.text = Localization.SearchHeaderView.NoResults
            case 1:
                label.text = Localization.SearchHeaderView.OneResult
            case 2...49:
                label.text = String.localizedStringWithFormat(Localization.SearchHeaderView.NResults, results)
            default:
                label.text = String.localizedStringWithFormat(Localization.SearchHeaderView.TooManyResults, results)
            }
            loadingIndicator.stopAnimating()
        }
    }
}
