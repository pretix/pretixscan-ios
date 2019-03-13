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

    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as? AppDelegate
    }

    // MARK: - Navigation
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkFirstRunActions(appDelegate.configStore!)
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let welcomeViewController = segue.destination as? WelcomeViewController {
            welcomeViewController.configStore = appDelegate.configStore
        }
    }
}

// MARK: First Run Actions
extension ValidateTicketViewController {
    func checkFirstRunActions(_ configStore: ConfigStore) {
        // First Run Warning Screen
        if !configStore.welcomeScreenIsConfirmed {
            performSegue(withIdentifier: Segue.presentWelcomeViewController, sender: self)
        }

        // API Connection
        else if !configStore.isConfigured {

        }
    }
}
