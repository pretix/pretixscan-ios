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
    }

    @IBAction func debugValidation(_ sender: Any) {
        let orderPosition = OrderPosition(
            identifier: 1842899, order: "RDTBG", positionid: 1, item: 25643, variation: nil, price: "250.00",
            attendeeName: "Daniel Jilg", attendeeEmail: nil, secret: "xmwtyuq5rf3794hwudf7smr6zgmbez9y",
            pseudonymizationId: "DAC7ULNMUB", checkins: []
        )
        redeem(orderPosition, force: false, ignoreUnpaid: false)
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

    func redeem(_ orderPosition: OrderPosition, force: Bool, ignoreUnpaid: Bool) {
        configStore.apiClient?.redeem(orderPosition, force: force, ignoreUnpaid: ignoreUnpaid,
                                      completionHandler: { (redemptionResponse, error) in
            self.presentErrorAlert(ifError: error)
            do {
                guard let response = redemptionResponse else { return }
                let alert = UIAlertController(title: "Redeem", message: "omsn", preferredStyle: .alert)

                switch response.status {
                case .redeemed:
                    alert.message = "VALID TICKET"
                case .incomplete:
                    alert.message = "INCOMPLETE"
                case .error:
                    if response.errorReason == .alreadyRedeemed {
                        alert.message = "TICKET ALREADY USED"
                    } else {
                        alert.message = "INVALID TICKET"
                    }

                }

                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: Segue.presentTicketStatusViewController, sender: self)
                }
            }

        })
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
