//
//  ValidateTicketViewController.swift
//  PretixScan
//
//  Created by Daniel Jilg on 13.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit
import Combine

class ValidateTicketViewController: UIViewController {
    @IBOutlet private weak var eventButton: UIBarButtonItem!
    private var searchController: UISearchController!
    private var ticketScannerViewController: TicketScannerViewController!
    private var anyCancellables = Set<AnyCancellable>()
    
    private var keyboardBuffer: String = ""
    
    var configStore: ConfigStore {
        guard let configStore = (UIApplication.shared.delegate as? AppDelegate)?.configStore else {
            fatalError("Could not get ConfigStore from AppDelegate")
        }
        return configStore
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Bundle.main.infoDictionary!["CFBundleDisplayName"] as? String
        
        // ConfigStore
        beginObservingNotifications()
        setupNavigationBarAppearance()
        setupSearchController()
    }
    
    // MARK: - View Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupEventButton()
        setupSearchController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkFirstRunActions()
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
        
        if let ticketScannerViewController = segue.destination as? TicketScannerViewController {
            self.ticketScannerViewController = ticketScannerViewController
        }
    }
}

// MARK: First Run Actions
extension ValidateTicketViewController {
    func checkFirstRunActions() {
        // First Run Welcome Screen
        if !configStore.welcomeScreenIsConfirmed {
            performSegue(withIdentifier: Segue.presentWelcomeViewController, sender: self)
        }
        
        // API Connection
        else if configStore.apiToken == nil {
            performSegue(withIdentifier: Segue.presentConnectDeviceViewController, sender: self)
        }
        
        else if configStore.event == nil || configStore.checkInList == nil {
            logger.warning("No event or checkInList has been selected")
            performSegue(withIdentifier: Segue.presentSelectEventTableViewController, sender: self)
        }
        
        // Begin Scanning
        else {
            ticketScannerViewController.canUseCamera = configStore.useDeviceCamera
            ticketScannerViewController.shouldScan = true
            configStore.syncManager.beginSyncingIfAutoSync()
        }
    }
}

// MARK: - AppCoordinator
extension ValidateTicketViewController: AppCoordinator {
    func getConfigStore() -> ConfigStore {
        return configStore
    }
    
    func redeem(secret: String, force: Bool, ignoreUnpaid: Bool) {
        if presentedViewController != nil {
            print("ticket status is currently being shown, we can't scan a code")
            return
        }
        
        if !ignoreUnpaid {
            getConfigStore().feedbackGenerator.announce(.didScanQrCode)
        }
        showStatusAndRedeem(secret, force, ignoreUnpaid)
    }
    
    func showStatusAndRedeem(_ secret: String, _ force: Bool, _ ignoreUnpaid: Bool) {
        let statusController = TicketStatusController()
        statusController.configuration = TicketStatusConfiguration(secret: secret, force: force, ignoreUnpaid: ignoreUnpaid, answers: nil)
        
        if let sheet = statusController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.preferredCornerRadius = 35
            sheet.delegate = statusController
        }
        
        present(statusController, animated: true, completion: nil)
    }
}

// MARK: - Setup
extension ValidateTicketViewController {
    private func setupNavigationBarAppearance() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithDefaultBackground()
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
    }
    
    private func setupSearchController() {
        if !configStore.enableSearch {
            logger.debug("🔎 Search is disabled")
            navigationItem.searchController?.dismiss(animated: false, completion: nil)
            navigationItem.searchController?.removeFromParent()
            navigationItem.searchController = nil
            return
        }
        
        if navigationItem.searchController != nil {
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let resultsViewController = storyboard.instantiateViewController(withIdentifier: "searchResults")
        guard let resultsController = resultsViewController as? SearchResultsTableViewController else {
            fatalError("Could not get get results view controller from Storyboard")
        }
        resultsController.appCoordinator = self
        searchController = UISearchController(searchResultsController: resultsController )
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = resultsController
        searchController.searchBar.placeholder = Localization.ValidateTicketViewController.SearchPlaceHolder
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func beginObservingNotifications() {
        // The ConfigStore is emmitting multiple events per second. At this time it's impractical to change this mechanism so here we need to throttle the updates in order for the cameraview to remain performant.
        
        NotificationCenter.default
            .publisher(for: configStore.changedNotification)
            .throttle(for: 1, scheduler: DispatchQueue.global(qos: .userInitiated), latest: true)
            .receive(on: RunLoop.main)
            .sink(receiveValue: {[weak self] notification in
                self?.onConfigStoreChanged(notification)
            })
            .store(in: &anyCancellables)
    }
    
    func onConfigStoreChanged(_ notification: Notification) {
        guard let value = notification.userInfo?["value"] as? ConfigStoreValue else {
            return
        }
        if [.event, .checkInList].contains(value) {
            self.setupEventButton()
            self.checkFirstRunActions()
        }
    }
    
    
    private func setupEventButton() {
        logger.debug("🔥 setupEventButton")
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

// MARK: - UIKeyInput
let keyboardHiderView = UIView()
extension ValidateTicketViewController: UIKeyInput {
    override var canBecomeFirstResponder: Bool { true }
    var hasText: Bool { false }
    
    override var inputView: UIView? {
        return keyboardHiderView
    }

    func insertText(_ text: String) {
        print("Keyboard character received: \(text)")
        if text == "\n" {
            let code = self.keyboardBuffer
            self.keyboardBuffer = ""
            print("Redeeming ticket from keyboard: \(code)")
            self.redeem(secret: code, force: false, ignoreUnpaid: false)
        } else {
            self.keyboardBuffer.append(text)
        }
    }

    func deleteBackward() {
        // do nothing
    }
}

// After using the search bar, the ValidateTicketViewController should become the first responder in order to handle scanner events
extension ValidateTicketViewController: UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.becomeFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.becomeFirstResponder()
    }
}
