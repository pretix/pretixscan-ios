//
//  ValidateTicketViewController.swift
//  PretixScan
//
//  Created by Daniel Jilg on 13.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class ValidateTicketViewController: UIViewController {
    weak var appDelegate: AppDelegate!

    @IBOutlet private weak var eventButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as? AppDelegate
    }

    // MARK: - Navigation
    override func viewWillAppear(_ animated: Bool) {
        eventButton.title = Localization.ValidateTicketViewController.NoEvent
        if let eventName = appDelegate.configStore?.event?.name.description,
            let checkInListName = appDelegate.configStore?.checkInList?.name {
            eventButton.title = "\(eventName): \(checkInListName)"
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkFirstRunActions(appDelegate.configStore!)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let configuredNavigationController = segue.destination as? ConfiguredNavigationController {
            configuredNavigationController.configStore = appDelegate.configStore
            configuredNavigationController.apiClient = appDelegate.apiClient
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
