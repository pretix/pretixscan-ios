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
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if var configStore = configStore {
            if indexPath == tableView.indexPath(for: offlineModeCell) {
                configStore.asyncModeEnabled = !(configStore.asyncModeEnabled)
                offlineModeCell.detailTextLabel?.text = configStore.asyncModeEnabled ?
                    Localization.SettingsTableViewController.SyncModeOffline : Localization.SettingsTableViewController.SyncModeOnline
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}
