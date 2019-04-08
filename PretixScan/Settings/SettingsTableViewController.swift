//
//  SettingsTableViewController.swift
//  PretixScan
//
//  Created by Daniel Jilg on 04.04.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, Configurable {
    var configStore: ConfigStore?

    @IBOutlet weak var versionCell: UITableViewCell!
    @IBOutlet weak var resetContentCell: UITableViewCell!
    @IBOutlet weak var offlineModeCell: UITableViewCell!
    @IBOutlet weak var swiftMessagesLicenseCell: UITableViewCell!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = Localization.SettingsTableViewController.Title
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        versionCell.textLabel?.text = Localization.SettingsTableViewController.Version
        versionCell.detailTextLabel?.text = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "n/a"

        resetContentCell.textLabel?.text = Localization.SettingsTableViewController.Reset

        offlineModeCell.textLabel?.text = Localization.SettingsTableViewController.SyncMode
        offlineModeCell.detailTextLabel?.text = configStore?.asyncModeEnabled == true ?
            Localization.SettingsTableViewController.SyncModeOffline : Localization.SettingsTableViewController.SyncModeOnline

        swiftMessagesLicenseCell.textLabel?.text = "SwiftMessages"
        swiftMessagesLicenseCell.detailTextLabel?.text = Localization.SettingsTableViewController.MITLicense
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // Offline Mode
        if indexPath == tableView.indexPath(for: offlineModeCell) {
            toggleOfflineMode()
        } else if indexPath == tableView.indexPath(for: resetContentCell) {
            reset()
        } else if indexPath == tableView.indexPath(for: swiftMessagesLicenseCell) {
            showSwiftMessagesLicense()
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionTitles = [
            Localization.SettingsTableViewController.AboutSectionTitle,
            Localization.SettingsTableViewController.ConfigurationSectionTitle,
            Localization.SettingsTableViewController.LicensesSectionTitle
        ]
        return sectionTitles[section]
    }

    // MARK: - Actions
    func toggleOfflineMode() {
        if var configStore = configStore {
            configStore.asyncModeEnabled = !(configStore.asyncModeEnabled)
            offlineModeCell.detailTextLabel?.text = configStore.asyncModeEnabled ?
                Localization.SettingsTableViewController.SyncModeOffline : Localization.SettingsTableViewController.SyncModeOnline
        }
    }

    func reset() {
        let alert = UIAlertController(
            title: Localization.SettingsTableViewController.Reset,
            message: Localization.SettingsTableViewController.ConfirmReset,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Localization.SettingsTableViewController.CancelReset, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: Localization.SettingsTableViewController.ContinueReset, style: .destructive, handler: { _ in
            self.configStore?.factoryReset()
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }

    func showSwiftMessagesLicense() {
        UIApplication.shared.open(URL(string: "https://github.com/SwiftKickMobile/SwiftMessages/blob/master/LICENSE.md")!, options: [:])
    }
}
