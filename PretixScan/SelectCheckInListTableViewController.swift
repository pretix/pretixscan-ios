//
//  SelectCheckInListTableViewController.swift
//  PretixScan
//
//  Created by Daniel Jilg on 18.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class SelectCheckInListTableViewController: UITableViewController, Configurable, APIUsing {
    var configStore: ConfigStore?
    var apiClient: APIClient?
    var event: Event?

    private var isLoading = true { didSet { DispatchQueue.main.async { self.tableView.reloadData() }}}
    private var checkInLists: [CheckInList]?

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Localization.SelectCheckInListTableViewController.Title
    }

    override func viewWillAppear(_ animated: Bool) {
        updateView()
    }

    private func updateView() {
        guard let configStore =  configStore, let apiClient = apiClient else {
            print("ConfigStore and APIStore not set, cancelling")
            return
        }

        guard let organizerSlug = configStore.organizerSlug else {
            print("No organizer Slug in config store, cancelling")
            return
        }

        guard let event = event else {
            print("No organizer event given, cancelling")
            return
        }

        apiClient.getCheckinLists(forOrganizer: organizerSlug, event: event) { (checkInLists, error) in
            if let error = error {
                fatalError(error.localizedDescription)
            }
            self.checkInLists = checkInLists
            self.isLoading = false
        }
    }

    // MARK: - Table view data source
    private static let reuseIdentifier = "SelectCheckInListTableViewControllerCell"
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checkInLists?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectCheckInListTableViewController.reuseIdentifier, for: indexPath)
        if let checkInList = checkInList(for: indexPath) {
            cell.textLabel?.text = checkInList.name
        }
        return cell
    }

    private func checkInList(for indexPath: IndexPath) -> CheckInList? {
        guard let checkInLists = checkInLists else { return nil }
        guard checkInLists.count > indexPath.row else { return nil }
        return checkInLists[indexPath.row]
    }

    // MARK: View Communication
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let selectedCell = sender as? UITableViewCell, let selectedIndexPath = tableView.indexPath(for: selectedCell) {
            let selectedCheckInList = checkInList(for: selectedIndexPath)
            configStore?.checkInList = selectedCheckInList
        }
    }
}
