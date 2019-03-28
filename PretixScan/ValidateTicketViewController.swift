//
//  ValidateTicketViewController.swift
//  PretixScan
//
//  Created by Daniel Jilg on 13.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class ValidateTicketViewController: UIViewController {
    var configStore: ConfigStore!

    @IBOutlet private weak var eventButton: UIBarButtonItem!
    private var searchController: UISearchController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Bundle.main.infoDictionary!["CFBundleName"] as? String

        // ConfigStore
        setupConfigStore()
        beginObservingNotifications()
        setupSearchController()
    }

    // MARK: - View Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        setupEventButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkFirstRunActions(configStore)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let configuredNavigationController = segue.destination as? ConfiguredNavigationController {
            configuredNavigationController.configStore = configStore
        }

        if var configurable = segue.destination as? Configurable {
            configurable.configStore = configStore
        }

        if let ticketStatusViewController = segue.destination as? TicketStatusViewController {
            ticketStatusViewController.redemptionResponse = sender as? RedemptionResponse
        }

        if let ticketScannerViewController = segue.destination as? TicketScannerViewController {
            ticketScannerViewController.appCoordinator = self
        }
    }
}

// MARK: First Run Actions
extension ValidateTicketViewController {
    func checkFirstRunActions(_ configStore: ConfigStore) {
        // First Run Welcome Screen
        if !configStore.welcomeScreenIsConfirmed {
            performSegue(withIdentifier: Segue.presentWelcomeViewController, sender: self)
        }

        // API Connection
        else if !configStore.isAPIConfigured {
            performSegue(withIdentifier: Segue.presentConnectDeviceViewController, sender: self)
        }
    }
}

// MARK: - AppCoordinator
extension ValidateTicketViewController: AppCoordinator {

    func getConfigStore() -> ConfigStore {
        return configStore
    }

    func redeem(secret: String, force: Bool, ignoreUnpaid: Bool) {
        configStore.apiClient?.redeem(secret: secret, force: force, ignoreUnpaid: ignoreUnpaid) { (redemptionResponse, error) in
            self.presentErrorAlert(ifError: error)
            do {
                guard let response = redemptionResponse else { return }

                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: Segue.presentTicketStatusViewController, sender: response)
                }
            }

        }
    }
}

// MARK: - Setup
extension ValidateTicketViewController {
    private func setupConfigStore() {
        guard let configStore = (UIApplication.shared.delegate as? AppDelegate)?.configStore else {
            fatalError("Could not get ConfigStore from AppDelegate")
        }
        self.configStore = configStore
    }

    private func setupSearchController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let resultsViewController = storyboard.instantiateViewController(withIdentifier: "searchResults")
        guard let resultsController = resultsViewController as? SearchResultsTableViewController else {
            fatalError("Could not get get results view controller from Storyboard")
        }
        resultsController.appCoordinator = self
        searchController = UISearchController(searchResultsController: resultsController )
        searchController.searchResultsUpdater = resultsController
        searchController.searchBar.placeholder = Localization.ValidateTicketViewController.SearchPlaceHolder
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    private func beginObservingNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(setupEventButton),
                                               name: configStore.changedNotification, object: nil)
    }

    @objc private func setupEventButton() {
        eventButton.title = Localization.ValidateTicketViewController.NoEvent
        if let eventName = configStore.event?.name.description,
            let checkInListName = configStore.checkInList?.name {
            eventButton.title = "\(eventName): \(checkInListName)"
        }
    }
}
