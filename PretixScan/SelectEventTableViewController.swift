//
//  SelectEventTableViewController.swift
//  PretixScan
//
//  Created by Daniel Jilg on 18.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class SelectEventTableViewController: UITableViewController, Configurable, APIUsing {
    var configStore: ConfigStore?
    var apiClient: APIClient?

    private var isLoading = true { didSet { DispatchQueue.main.async { self.tableView.reloadData() }}}
    private var events: [Event]?
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Localization.SelectEventTableViewController.Title
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

        apiClient.getEvents(forOrganizer: organizerSlug) { (eventList, error) in
            if let error = error {
                fatalError(error.localizedDescription)
            }
            self.events = eventList
            self.isLoading = false
        }
    }

    // MARK: Loading

    // MARK: - Table view data source
    private static let reuseIdentifier = "SelectEventTableViewControllerCell"
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectEventTableViewController.reuseIdentifier, for: indexPath)
        if let event = event(for: indexPath) {
            cell.textLabel?.text = event.name.description
            if let date = event.dateFrom {
                cell.detailTextLabel?.text = dateFormatter.string(from: date)
            }
        }
        return cell
    }

    private func event(for indexPath: IndexPath) -> Event? {
        guard let events = events else { return nil }
        guard events.count > indexPath.row else { return nil }
        return events[indexPath.row]
    }
}
