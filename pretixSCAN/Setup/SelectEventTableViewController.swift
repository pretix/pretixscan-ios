//
//  SelectEventTableViewController.swift
//  PretixScan
//
//  Created by Daniel Jilg on 18.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class SelectEventTableViewController: UITableViewController, Configurable {
    var configStore: ConfigStore?

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

    private var events: [Event]?
    private var subEvents: [Event: [SubEvent]]?
    var showingResetDevice: Bool = false

    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Localization.SelectEventTableViewController.Title
        refreshControl?.addTarget(self, action: #selector(updateView), for: .valueChanged)
        
        if !showingResetDevice {
            setLeadingNavBarAction(title: Localization.Common.dismiss, selector: #selector(self.hide), target: self)
        } else {
            clearLeadingBavBarAction()
            hideNavBarBackButton()
            setTrailingNavBarAction(title:  Localization.SelectEventTableViewController.ResetDevice, selector: #selector(self.confirmFactoryReset), target: self)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        updateView()
    }
    
    @objc func hide() {
        self.dismiss(animated: true)
    }

    @objc private func updateView() {
        isLoading = true
        events = nil
        subEvents = [:]

        var subEventsLoading = 0
        hideEmptyMessage()

        configStore?.ticketValidator?.getEvents { (eventList, error) in
            self.presentErrorAlert(ifError: error)
            self.events = eventList
            if let events = self.events {
                if events.isEmpty {
                    self.isLoading = false
                    self.showEmptyMessage()
                }
                subEventsLoading = events.count
                for event in events {
                    guard event.hasSubEvents else {
                        subEventsLoading -= 1
                        if subEventsLoading < 1 {
                            self.isLoading = false
                        }

                        continue
                    }

                    self.configStore?.ticketValidator?.getSubEvents(event: event) { (subeventList, error) in
                        subEventsLoading -= 1
                        self.presentErrorAlert(ifError: error)

                        if let subeventList = subeventList {
                            self.subEvents?[event] = subeventList
                        }

                        if subEventsLoading < 1 {
                            self.isLoading = false
                        }
                    }
                }
            } else {
                self.isLoading = false
                self.showEmptyMessage()
            }
            
        }
    }
    
    func showEmptyMessage() {
        DispatchQueue.main.async {[weak self] in
            self?.setBackgroundMessage(Localization.SelectEventTableViewController.NoEventsToShowError)
        }
    }

    // MARK: - Table view data source
    private static let reuseIdentifier = "SelectEventTableViewControllerCell"
    override func numberOfSections(in tableView: UITableView) -> Int {
        return events?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let event = events?[section] else { return 0 }
        guard let subEventsCount = subEvents?[event]?.count else { return 1 }
        return subEventsCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectEventTableViewController.reuseIdentifier, for: indexPath)

        if let subEvent = subEvent(for: indexPath) {
            cell.textLabel?.text = subEvent.name.representation(in: Locale.current)
            cell.detailTextLabel?.text = dateFormatter.string(from: subEvent.dateFrom)
        } else if let event = event(for: indexPath) {
            cell.textLabel?.text = event.name.representation(in: Locale.current)
            if let date = event.dateFrom {
                cell.detailTextLabel?.text = dateFormatter.string(from: date)
            }
        }

        return cell
    }

    private func event(for indexPath: IndexPath) -> Event? {
        guard let events = events else { return nil }
        guard events.count > indexPath.section else { return nil }
        return events[indexPath.section]
    }

    private func subEvent(for indexPath: IndexPath) -> SubEvent? {
        guard let events = events else { return nil }
        guard events.count > indexPath.section else { return nil }
        let event = events[indexPath.section]

        return subEvents?[event]?[indexPath.row]
    }

    // MARK: View Communication
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let selectCheckInListViewController = segue.destination as? SelectCheckInListTableViewController,
            let selectedCell = sender as? UITableViewCell,
            let selectedIndexPath = tableView.indexPath(for: selectedCell) {

            let selectedEvent = event(for: selectedIndexPath)
            let selectedSubEvent = subEvent(for: selectedIndexPath)
            selectCheckInListViewController.event = selectedEvent
            selectCheckInListViewController.subEvent = selectedSubEvent
        }
    }
    
    // MARK: Sign out
    @objc func confirmFactoryReset() {
        let alert = UIAlertController(
            title: Localization.SettingsTableViewController.PerformFactoryReset,
            message: Localization.SettingsTableViewController.FactoryResetConfirmMessage,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Localization.SettingsTableViewController.CancelReset, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: Localization.SettingsTableViewController.ConfirmReset, style: .destructive, handler: { [weak self] _ in
            self?.configStore?.factoryReset()
            self?.configStore?.syncManager.resetSyncState()
            self?.dismiss(animated: true)
            if let validateController = (self?.presentingViewController as? UINavigationController)?.viewControllers[0] as? ValidateTicketViewController {
                // as this is a modal, the first run actions will not run automatically
                DispatchQueue.main.async {
                    validateController.checkFirstRunActions()
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

private extension SelectEventTableViewController {

    /// Update the background of the tableView to show a message
    func setBackgroundMessage(_ message: String) {
        let messageLabel = LabelWithPadding(withInsets: 20, 20, 20, 20)
        messageLabel.text = message
        messageLabel.textColor = PXColor.dynamicText
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.sizeToFit()
        self.tableView.backgroundView = messageLabel
    }

    /// Remove the background of the tableView
    func hideEmptyMessage() {
        self.tableView.backgroundView = nil
    }
}
