//
//  SettingsTableViewController.swift
//  PretixScan
//
//  Created by Daniel Jilg on 04.04.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit
import Combine

class SettingsTableViewController: UITableViewController, Configurable {
    var configStore: ConfigStore?
    
    @IBOutlet weak var gateCell: UITableViewCell!
    @IBOutlet weak var versionCell: UITableViewCell!
    @IBOutlet weak var shouldAutoSyncCell: UITableViewCell!
    @IBOutlet weak var shouldDownloadOrdersCell: UITableViewCell!
    @IBOutlet weak var scanModeCell: UITableViewCell!
    @IBOutlet weak var beginSyncingCell: UITableViewCell!
    @IBOutlet weak var forceSyncCell: UITableViewCell!
    @IBOutlet weak var resetContentCell: UITableViewCell!
    @IBOutlet weak var offlineModeCell: SettingsTableViewExplanationCell!
    @IBOutlet weak var playSoundsCell: UITableViewCell!
    @IBOutlet weak var useCameraCell: UITableViewCell!
    @IBOutlet weak var preferFrontCameraCell: UITableViewCell!
    
    
    @IBOutlet weak var libraryLicenseCell1: UITableViewCell!
    @IBOutlet weak var libraryLicenseCell2: UITableViewCell!
    @IBOutlet weak var libraryLicenseCell3: UITableViewCell!
    @IBOutlet weak var libraryLicenseCell4: UITableViewCell!
    @IBOutlet weak var libraryLicenseCell5: UITableViewCell!
    @IBOutlet weak var libraryLicenseCell6: UITableViewCell!
    @IBOutlet weak var libraryLicenseCell7: UITableViewCell!
    
    var libraryLicenseCells = [UITableViewCell]()
    private var anyCancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Localization.SettingsTableViewController.Title
        libraryLicenseCells = [libraryLicenseCell1, libraryLicenseCell2, libraryLicenseCell3, libraryLicenseCell4, libraryLicenseCell5, libraryLicenseCell6, libraryLicenseCell7]
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
        
        useCameraCell.textLabel?.text = Localization.SettingsTableViewController.UseCamera
        useCameraCell.detailTextLabel?.text = configStore?.useDeviceCamera == true ? Icon.enabled : Icon.disabled
        
        preferFrontCameraCell.textLabel?.text = Localization.SettingsTableViewController.PreferFrontCamera
        preferFrontCameraCell.detailTextLabel?.text = configStore?.preferFrontCamera == true ? Icon.enabled : Icon.disabled
        
        beginSyncingCell.textLabel?.text = Localization.SettingsTableViewController.BeginSyncing
        forceSyncCell.textLabel?.text = Localization.SettingsTableViewController.ForceSync
        
        versionCell.textLabel?.text = Localization.SettingsTableViewController.Version
        versionCell.detailTextLabel?.text = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "n/a"
        
        setAppInfoFromConfig()
        
        resetContentCell.textLabel?.text = Localization.SettingsTableViewController.PerformFactoryReset
        
        offlineModeCell.valueLabel?.text = configStore?.asyncModeEnabled == true ?
        Localization.SettingsTableViewController.SyncModeOffline : Localization.SettingsTableViewController.SyncModeOnline
        offlineModeCell.titleLabel?.text = Localization.SettingsTableViewController.SyncMode
        offlineModeCell.explanationLabel.text = Localization.SettingsTableViewController.SyncModeExplanation
        
        for (ix, library) in AppPackageLicenses.enumerated() {
            libraryLicenseCells[ix].textLabel?.text = library.name
            libraryLicenseCells[ix].detailTextLabel?.text = NSLocalizedString(library.license, comment: "")
        }
        
        beginObservingNotifications()
    }
    
    func setAppInfoFromConfig() {
        gateCell.textLabel?.text = Localization.SettingsTableViewController.Gate
        gateCell.detailTextLabel?.text = configStore?.deviceKnownGateName ?? "---"
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
        } else if let licenseCellIx = libraryLicenseCells.firstIndex(where: {indexPath == tableView.indexPath(for: $0)}) {
            showLicense(for: licenseCellIx)
        } else if indexPath == tableView.indexPath(for: playSoundsCell) {
            toggleShouldPlaySounds()
        } else if indexPath == tableView.indexPath(for: shouldDownloadOrdersCell) {
            toggleShouldDownloadOrders()
        } else if indexPath == tableView.indexPath(for: useCameraCell) {
            toggleUseDeviceCamera()
        } else if indexPath == tableView.indexPath(for: preferFrontCameraCell) {
            togglePreferFrontCamera()
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
    
    private func beginObservingNotifications() {
        NotificationCenter.default
            .publisher(for: configStore!.changedNotification)
            .receive(on: RunLoop.main)
            .sink(receiveValue: {[weak self] notification in
                self?.onConfigStoreChanged(notification)
            })
            .store(in: &anyCancellables)
    }
    
    func onConfigStoreChanged(_ notification: Notification) {
        guard let _ = notification.userInfo?["value"] as? ConfigStoreValue else {
            return
        }
        setAppInfoFromConfig()
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
    
    func toggleUseDeviceCamera() {
        configStore?.useDeviceCamera.toggle()
        useCameraCell.detailTextLabel?.text = configStore?.useDeviceCamera == true ? Icon.enabled : Icon.disabled
        configStore?.valueChanged(.useDeviceCamera)
    }
    
    func togglePreferFrontCamera() {
        configStore?.preferFrontCamera.toggle()
        preferFrontCameraCell.detailTextLabel?.text = configStore?.preferFrontCamera == true ? Icon.enabled : Icon.disabled
        configStore?.valueChanged(.preferFrontCamera)
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
            self.configStore?.syncManager.resetSyncState()
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showLicense(for packageIx: Int) {
        let license = AppPackageLicenses[packageIx]
        guard let url = URL(string: license.url) else {
            logger.error("Failed to create url for package \(license.name).")
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            logger.error("OS dennied opening url for package \(license.name) (canOpenURL = false).")
        }
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
