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
    private var ticketScannerViewController: TicketScannerViewController!

    private let notificationFeedbackGenerator = UINotificationFeedbackGenerator()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Bundle.main.infoDictionary!["CFBundleDisplayName"] as? String

        // ConfigStore
        setupConfigStore()
        beginObservingNotifications()
        setupNavigationBarAppearance()
        setupSearchController()
    }

    // MARK: - View Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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

        if var appCoordinatorReceiver = segue.destination as? AppCoordinatorReceiver {
            appCoordinatorReceiver.appCoordinator = self
        }

        if let ticketStatusViewController = segue.destination as? TicketStatusViewController {
            ticketStatusViewController.configuration = sender as? TicketStatusViewController.Configuration
        }

        if let ticketScannerViewController = segue.destination as? TicketScannerViewController {
            self.ticketScannerViewController = ticketScannerViewController
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
        else if configStore.apiToken == nil {
            performSegue(withIdentifier: Segue.presentConnectDeviceViewController, sender: self)
        }

        // Begin Scanning
        else {
            ticketScannerViewController.shouldScan = true
            configStore.syncManager.beginSyncingIfAutoSync()
        }
    }
}

// MARK: - AppCoordinator
extension ValidateTicketViewController: AppCoordinator {
    func performHapticNotification(ofType type: UINotificationFeedbackGenerator.FeedbackType) {
        notificationFeedbackGenerator.notificationOccurred(type)
    }

    func getConfigStore() -> ConfigStore {
        return configStore
    }

    func redeem(secret: String, force: Bool, ignoreUnpaid: Bool) {
        let ticketStatusViewControllerConfiguration = TicketStatusViewController.Configuration(
            secret: secret, force: force, ignoreUnpaid: ignoreUnpaid, answers: nil)
        self.performSegue(withIdentifier: Segue.presentTicketStatusViewController, sender: ticketStatusViewControllerConfiguration)
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

    private func setupNavigationBarAppearance() {
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithDefaultBackground()

            navigationController?.navigationBar.standardAppearance = navBarAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        }
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
        DispatchQueue.main.async {
            self.eventButton.title = Localization.ValidateTicketViewController.NoEvent
            if let eventName = self.configStore.event?.name.representation(in: Locale.current),
                let checkInListName = self.configStore.checkInList?.name {
                self.eventButton.title = "\(eventName): \(checkInListName)"
            }
            if self.configStore.scanMode == "exit" {
                self.title = (Bundle.main.infoDictionary!["CFBundleDisplayName"] as? String ?? "") + " (" + Localization.SettingsTableViewController.Exit + ")"
            } else {
                self.title = Bundle.main.infoDictionary!["CFBundleDisplayName"] as? String
            }
        }
    }
}
