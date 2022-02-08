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
    @IBOutlet weak var shouldAutoSyncCell: UITableViewCell!
    @IBOutlet weak var shouldDownloadOrdersCell: UITableViewCell!
    @IBOutlet weak var scanModeCell: UITableViewCell!
    @IBOutlet weak var beginSyncingCell: UITableViewCell!
    @IBOutlet weak var forceSyncCell: UITableViewCell!
    @IBOutlet weak var resetContentCell: UITableViewCell!
    @IBOutlet weak var offlineModeCell: SettingsTableViewExplanationCell!
    @IBOutlet weak var swiftMessagesLicenseCell: UITableViewCell!
    @IBOutlet weak var fmdbLicenseCell: UITableViewCell!
    @IBOutlet weak var tinkKeyChainLicenseCell: UITableViewCell!
    @IBOutlet weak var playSoundsCell: UITableViewCell!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = Localization.SettingsTableViewController.Title
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        scanModeCell.textLabel?.text = Localization.SettingsTableViewController.ScanMode
        scanModeCell.detailTextLabel?.text = configStore?.scanMode == "exit" ? Localization.SettingsTableViewController.Exit : Localization.SettingsTableViewController.Entry

        shouldAutoSyncCell.textLabel?.text = Localization.SettingsTableViewController.ShouldAutoSync
        shouldAutoSyncCell.detailTextLabel?.text = configStore?.shouldAutoSync == true ? Icon.enabled : Icon.disabled
        
        shouldDownloadOrdersCell.textLabel?.text = Localization.SettingsTableViewController.DownloadOrders
        shouldDownloadOrdersCell.detailTextLabel?.text = configStore?.shouldDownloadOrders == true ? Icon.enabled : Icon.disabled
       
        playSoundsCell.textLabel?.text = Localization.SettingsTableViewController.PlaySounds
        playSoundsCell.detailTextLabel?.text = configStore?.shouldPlaySounds == true ? Icon.enabled : Icon.disabled
        
        beginSyncingCell.textLabel?.text = Localization.SettingsTableViewController.BeginSyncing
        forceSyncCell.textLabel?.text = Localization.SettingsTableViewController.ForceSync

        versionCell.textLabel?.text = Localization.SettingsTableViewController.Version
        versionCell.detailTextLabel?.text = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "n/a"

        resetContentCell.textLabel?.text = Localization.SettingsTableViewController.PerformFactoryReset

        offlineModeCell.valueLabel?.text = configStore?.asyncModeEnabled == true ?
            Localization.SettingsTableViewController.SyncModeOffline : Localization.SettingsTableViewController.SyncModeOnline
        offlineModeCell.titleLabel?.text = Localization.SettingsTableViewController.SyncMode
        offlineModeCell.explanationLabel.text = Localization.SettingsTableViewController.SyncModeExplanation

        swiftMessagesLicenseCell.textLabel?.text = "SwiftMessages"
        swiftMessagesLicenseCell.detailTextLabel?.text = Localization.SettingsTableViewController.MITLicense

        fmdbLicenseCell.textLabel?.text = "FMDB"
        fmdbLicenseCell.detailTextLabel?.text = Localization.SettingsTableViewController.MITLicense

        tinkKeyChainLicenseCell.textLabel?.text = "Tink Keychain"
        tinkKeyChainLicenseCell.detailTextLabel?.text = Localization.SettingsTableViewController.MITLicense
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath == tableView.indexPath(for: shouldAutoSyncCell) {
            toggleShouldAutoSync()
        } else if indexPath == tableView.indexPath(for: scanModeCell) {
            toggleScanMode()
        } else if indexPath == tableView.indexPath(for: forceSyncCell) {
            forceSync()
        } else if indexPath == tableView.indexPath(for: beginSyncingCell) {
            beginSyncing()
        } else if indexPath == tableView.indexPath(for: offlineModeCell) {
            toggleOfflineMode()
        } else if indexPath == tableView.indexPath(for: resetContentCell) {
            configStoreFactoryReset()
        } else if indexPath == tableView.indexPath(for: swiftMessagesLicenseCell) {
            showSwiftMessagesLicense()
        } else if indexPath == tableView.indexPath(for: fmdbLicenseCell) {
            showFMDBLicense()
        } else if indexPath == tableView.indexPath(for: tinkKeyChainLicenseCell) {
            showTinkKeyChainLicense()
        } else if indexPath == tableView.indexPath(for: playSoundsCell) {
            toggleShouldPlaySounds()
        } else if indexPath == tableView.indexPath(for: shouldDownloadOrdersCell) {
            toggleShouldDownloadOrders()
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionTitles = [
            Localization.SettingsTableViewController.ConfigurationSectionTitle,
            Localization.SettingsTableViewController.UserInterfaceSectionTitle,
            Localization.SettingsTableViewController.AboutSectionTitle,
            Localization.SettingsTableViewController.LicensesSectionTitle
        ]
        return sectionTitles[section]
    }
    
    // MARK: - Actions
    func toggleScanMode() {
        guard let configStore = configStore else { return }
        let previousValue = configStore.scanMode
        if (previousValue == "exit") {
            configStore.scanMode = "entry"
        } else {
            configStore.scanMode = "exit"
        }

        scanModeCell.detailTextLabel?.text = configStore.scanMode == "exit" ? Localization.SettingsTableViewController.Exit : Localization.SettingsTableViewController.Entry
    }

    func toggleShouldDownloadOrders() {
        guard let configStore = configStore else { return }
        configStore.shouldDownloadOrders.toggle()
        shouldDownloadOrdersCell.detailTextLabel?.text = configStore.shouldDownloadOrders == true ? Icon.enabled : Icon.disabled
    }
    
    func toggleShouldAutoSync() {
        guard let configStore = configStore else { return }
        let previousValue = configStore.shouldAutoSync
        configStore.shouldAutoSync = !previousValue

        shouldAutoSyncCell.detailTextLabel?.text = configStore.shouldAutoSync == true ? Icon.enabled : Icon.disabled

        configStore.syncManager.beginSyncingIfAutoSync()
    }

    func toggleShouldPlaySounds() {
        configStore?.shouldPlaySounds.toggle()
        playSoundsCell.detailTextLabel?.text = configStore?.shouldPlaySounds == true ? Icon.enabled : Icon.disabled
    }
    
    func beginSyncing() {
        configStore?.syncManager.beginSyncing()
    }

    func forceSync() {
        configStore?.syncManager.forceSync()
    }

    func toggleOfflineMode() {
        if let configStore = configStore {
            configStore.asyncModeEnabled = !(configStore.asyncModeEnabled)
            offlineModeCell.valueLabel?.text = configStore.asyncModeEnabled ?
                Localization.SettingsTableViewController.SyncModeOffline : Localization.SettingsTableViewController.SyncModeOnline
        }
    }

    func configStoreFactoryReset() {
        let alert = UIAlertController(
            title: Localization.SettingsTableViewController.PerformFactoryReset,
            message: Localization.SettingsTableViewController.FactoryResetConfirmMessage,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Localization.SettingsTableViewController.CancelReset, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: Localization.SettingsTableViewController.ConfirmReset, style: .destructive, handler: { _ in
            self.configStore?.factoryReset()
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }

    func showSwiftMessagesLicense() {
        UIApplication.shared.open(URL(string: "https://github.com/SwiftKickMobile/SwiftMessages/blob/master/LICENSE.md")!, options: [:])
    }

    func showFMDBLicense() {
        UIApplication.shared.open(URL(string: "https://github.com/ccgus/fmdb/blob/master/LICENSE.txt")!, options: [:])
    }

    func showTinkKeyChainLicense() {
        UIApplication.shared.open(URL(string: "https://github.com/tink-ab/Keychain/blob/master/LICENSE")!, options: [:])
    }
}
