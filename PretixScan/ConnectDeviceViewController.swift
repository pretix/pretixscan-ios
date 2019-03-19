//
//  ConnectDeviceViewController.swift
//  PretixScan
//
//  Created by Daniel Jilg on 13.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class ConnectDeviceViewController: UIViewController, Configurable {
    var configStore: ConfigStore?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var explanationLabel: UILabel!
    @IBOutlet weak var manualSetupButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = Localization.ConnectDeviceViewController.Title
        titleLabel.text = Localization.ConnectDeviceViewController.Title
        explanationLabel.text = Localization.ConnectDeviceViewController.Explanation
        manualSetupButton.title = Localization.ConnectDeviceViewController.ManualSetup
    }

    @IBAction private func manualSetup(_ sender: Any) {
        guard var configStore = self.configStore else {
            print("configStore not available")
            return
        }

        let alert = UIAlertController(
            title: Localization.ConnectDeviceViewController.ManualSetupTitle,
            message: Localization.ConnectDeviceViewController.ManualSetupMessage,
            preferredStyle: .alert
        )
        alert.addTextField {
            $0.placeholder = Localization.ConnectDeviceViewController.URL
            $0.text = "https://pretix.eu"
        }
        alert.addTextField { $0.placeholder = Localization.ConnectDeviceViewController.Token }
        alert.addAction(UIAlertAction(title: Localization.ConnectDeviceViewController.Cancel, style: .cancel))

        alert.addAction(UIAlertAction(title: Localization.ConnectDeviceViewController.Connect, style: .default) { _ in
            guard alert.textFields?.count ?? 0 >= 2 else { return }
            guard let urlString = alert.textFields![0].text else { return }
            guard let url = URL(string: urlString) else { return }
            guard let token = alert.textFields![1].text else { return }

            configStore.apiBaseURL = url

            let deviceInitializatioRequest = DeviceInitializationRequest.init(
                token: token,
                hardwareBrand: "Apple",
                hardwareModel: UIDevice.current.modelName,
                softwareBrand: Bundle.main.infoDictionary!["CFBundleName"] as? String ?? "n/a",
                softwareVersion: Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "n/a"
            )

            self.configStore?.apiClient?.initialize(deviceInitializatioRequest) { error in
                if let error = error {
                    fatalError(error.localizedDescription)
                }

                // API Client is correctly initialized
                DispatchQueue.main.async {
                    (self.navigationController as? ConfiguredNavigationController)?.configStore = self.configStore
                    self.performSegue(withIdentifier: Segue.presentSelectEventTableViewController, sender: self)
                }
            }
        })
        present(alert, animated: true)
    }
}
