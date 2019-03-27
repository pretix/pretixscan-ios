//
//  CheckInStatusTableViewController.swift
//  PretixScan
//
//  Created by Daniel Jilg on 27.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class CheckInStatusTableViewController: UITableViewController, Configurable {
    // MARK: - Public and Non-Private Properties
    var configStore: ConfigStore?

    // MARK: - Private Properties
    private enum Section: Int {
        case overview = 0
        case detail = 1
    }
    private var sections: [Section] = [.overview, .detail]

    private var isLoading = true {
        didSet {
            DispatchQueue.main.async {
                if self.isLoading {
                    self.tableView.refreshControl?.beginRefreshing()
                } else {
                    self.tableView.refreshControl?.endRefreshing()
                }
                self.tableView.reloadData()
            }
        }
    }

    private var checkInListStatus: CheckInListStatus?

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Localization.CheckInStatusTableViewController.Title
        refreshControl?.addTarget(self, action: #selector(updateView), for: .valueChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        updateView()
    }

    @objc private func updateView() {
        isLoading = true

        configStore?.apiClient?.getCheckInListStatus { (checkInListStatus, error) in
            self.presentErrorAlert(ifError: error)
            self.checkInListStatus = checkInListStatus
            self.isLoading = false
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionDescriptor = Section(rawValue: section) else { return 0 }
        switch sectionDescriptor {
        case .overview:
            return checkInListStatus == nil ? 0 : 1
        case .detail:
            return checkInListStatus?.items.count ?? 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = Section(rawValue: indexPath.section)!
        switch section {

        case .overview:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: CheckInStatusOverviewTableViewCell.reuseIdentifier,
                for: indexPath)
            if let cell = cell as? CheckInStatusOverviewTableViewCell {
                cell.checkInListStatus = self.checkInListStatus
            }
            return cell

        case .detail:
            let item = checkInStatusItem(for: indexPath)
            if let variations = item?.variations, variations.count > 0 {
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: AdvancedCheckInStatusItemTableViewCell.reuseIdentifier,
                    for: indexPath)
                if let cell = cell as? AdvancedCheckInStatusItemTableViewCell {
                    cell.checkInListStatusItem = item
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: SimpleCheckInStatusItemTableViewCell.reuseIdentifier,
                    for: indexPath)
                if let cell = cell as? SimpleCheckInStatusItemTableViewCell {
                    cell.checkInListStatusItem = item
                }
                return cell
            }
        }
    }

    private func checkInStatusItem(for indexPath: IndexPath) -> CheckInListStatus.Item? {
        guard indexPath.section == Section.detail.rawValue else { return nil }
        guard let checkInListStatus = checkInListStatus else { return nil }
        guard checkInListStatus.items.count > indexPath.row else { return nil }
        return checkInListStatus.items[indexPath.row]
    }
}
