//
//  DefaultsConfigStore.swift
//  PretixScan
//
//  Created by Daniel Jilg on 03.04.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation
import Sentry

/// ConfigStore implementation that stores configuration in UserDefaults.
///
/// Saving occurs automatically each time a property is set.
///
/// Loading occurs at init time. You can also load manually by calling `loadFromDefaults()`.
public class DefaultsConfigStore: ConfigStore {
    private var defaults: UserDefaults

    enum Keys: String, CaseIterable {
        case welcomeScreenIsConfirmed
        case apiBaseURL
        case apiToken
        case apiClient
        case deviceName
        case organizerSlug
        case deviceID
        case securityProfile
        case deviceUniqueSerial
        case event
        case checkInList
        case allManagedEvents
        case asyncModeEnabled
        case scanMode
        case shouldPlaySounds
        case useDeviceCamera
        case shouldDownloadOrders
        case shouldAutoSync
        case publishedSoftwareVersion
        case enableSearch
    }

    public var enableSearch: Bool {
        get { return _enableSearch }
        set {
            _enableSearch = newValue
            valueChanged()
        }
    }
    
    public var welcomeScreenIsConfirmed: Bool {
        get { return _welcomeScreenIsConfirmed }
        set {
            _welcomeScreenIsConfirmed = newValue
            valueChanged()
        }
    }

    public var apiBaseURL: URL? {
        get { return _apiBaseURL }
        set {
            _apiBaseURL = newValue
            valueChanged()
        }
    }

    public var apiToken: String? {
        get { return _apiToken }
        set {
            _apiToken = newValue
            valueChanged(.apiToken)
        }
    }

    public var apiClient: APIClient? {
        _apiClient = _apiClient ?? APIClient(configStore: self)
        return _apiClient
    }

    public var ticketValidator: TicketValidator? {
        if !_asyncModeEnabled {
            // Online Mode
            _onlineTicketValidator = _onlineTicketValidator ?? OnlineTicketValidator(configStore: self)
            return _onlineTicketValidator
        } else {
            // Ofline mode
            _offlineTicketValidator = _offlineTicketValidator ?? OfflineTicketValidator(configStore: self)
            return _offlineTicketValidator
        }
    }
    
    public var feedbackGenerator: FeedbackGenerator {
        return _feedbackGenerator
            .setMode(_asyncModeEnabled ? FeedbackMode.offline : FeedbackMode.online)
            .setPlaySounds(shouldPlaySounds)
    }

    public var syncManager: SyncManager {
        _syncManager = _syncManager ?? SyncManager(configStore: self)
        return _syncManager!
    }

    public var dataStore: DataStore? {
        _dataStore = _dataStore ?? FMDBDataStore()
        return _dataStore
    }

    public var deviceName: String? {
        get { return _deviceName }
        set {
            _deviceName = newValue
            valueChanged()
        }
    }

    public var organizerSlug: String? {
        get { return _organizerSlug }
        set {
            _organizerSlug = newValue
            valueChanged(.organizerSlug)
        }
    }

    public var deviceID: Int? {
        get { return _deviceID }
        set {
            _deviceID = newValue
            valueChanged()
        }
    }
    
    public var securityProfile: PXSecurityProfile {
        get { return _securityProfile }
        set {
            _securityProfile = newValue
            valueChanged()
        }
    }

    public var deviceUniqueSerial: String? {
        get { return _deviceUniqueSerial }
        set {
            _deviceUniqueSerial = newValue
            valueChanged()
        }
    }

    public var scanMode: String {
        get { return _scanMode }
        set {
            _scanMode = newValue
            valueChanged()
        }
    }

    public private(set) var event: Event? {
        get { return _event }
        set {
            _event = newValue
            valueChanged(.event)
        }
    }

    public private(set) var checkInList: CheckInList? {
        get { return _checkInList }
        set {
            _checkInList = newValue
            valueChanged(.checkInList)
        }
    }

    public func set(event: Event, checkInList: CheckInList) {
        if !allManagedEvents.contains(event) {
            self.allManagedEvents.append(event)
        }

        self.event = event
        self.checkInList = checkInList
        
        saveToDefaults()

        SentrySDK.configureScope { scope in
            scope.setTags(["event": event.slug, "checkInList": "\(checkInList.identifier)"])
        }
    }

    /// All Events that are synced into a local database
    public private(set) var allManagedEvents: [Event] {
        get {
            return _allManagedEvents
        }
        set {
            _allManagedEvents = newValue
            valueChanged(.allManagedEvents)
        }
    }

    public var asyncModeEnabled: Bool {
        get {
            return _asyncModeEnabled
        }
        set {
            _asyncModeEnabled = newValue
            valueChanged(.asyncModeEnabled)
        }
    }

    public var shouldAutoSync: Bool {
        get {
            return _shouldAutoSync
        }
        set {
            _shouldAutoSync = newValue
            valueChanged(.shouldAutoSync)
        }
    }
    
    public var shouldPlaySounds: Bool = false {
        didSet {
            save(shouldPlaySounds, forKey: .shouldPlaySounds)
        }
    }
    
    public var useDeviceCamera: Bool = false {
        didSet {
            save(useDeviceCamera, forKey: .useDeviceCamera)
        }
    }
    
    public var shouldDownloadOrders: Bool = false {
        didSet {
            save(shouldDownloadOrders, forKey: .shouldDownloadOrders)
        }
    }
    
    public var publishedSoftwareVersion: String? {
        get {
            return _publishedVersion
        }
        set {
            _publishedVersion = newValue
            valueChanged()
        }
    }

    private var _welcomeScreenIsConfirmed: Bool = false
    private var _apiBaseURL: URL?
    private var _apiToken: String?
    private var _apiClient: APIClient?
    private var _offlineTicketValidator: OfflineTicketValidator?
    private var _onlineTicketValidator: OnlineTicketValidator?
    private var _syncManager: SyncManager?
    private var _feedbackGenerator: FeedbackGenerator = ScanFeedbackGenerator()
    private var _dataStore: DataStore?
    private var _deviceName: String?
    private var _organizerSlug: String?
    private var _deviceID: Int?
    private var _securityProfile: PXSecurityProfile = .full
    private var _deviceUniqueSerial: String?
    private var _scanMode: String = "entry"
    private var _event: Event?
    private var _checkInList: CheckInList?
    private var _allManagedEvents: [Event] = []
    private var _asyncModeEnabled: Bool = false
    private var _shouldAutoSync: Bool = true
    private var _enableSearch: Bool = true
    private var _publishedVersion: String? = nil

    private let jsonEncoder = JSONEncoder.iso8601withFractionsEncoder
    private let jsonDecoder = JSONDecoder.iso8601withFractionsDecoder

    init(defaults: UserDefaults) {
        self.defaults = defaults
        registerInitialValues()
        loadFromDefaults()
        printDeviceIdentity()
    }
    
    public func applySecurityDefaults() {
        shouldDownloadOrders = self.securityProfile.defaultValue(for: .shouldDownloadOrders)
        enableSearch = self.securityProfile.defaultValue(for: .enableSearch)
    }

    public func factoryReset() {
        for event in allManagedEvents {
            dataStore?.destroyDataStore(for: event, recreate: false)
        }

        dataStore?.destroyDataStoreForUploads()
        _dataStore = nil

        purgeAllSettings()
        
        PXTemporaryFile.cleanUpAll()
        
        _welcomeScreenIsConfirmed = false
        _apiBaseURL = nil
        _apiToken = nil
        _apiClient = nil
        _deviceName = nil
        _organizerSlug = nil
        _deviceID = nil
        _securityProfile = .full
        _deviceUniqueSerial = nil
        _scanMode = "entry"
        _event = nil
        _checkInList = nil
        _allManagedEvents = []
        _asyncModeEnabled = false
        _shouldAutoSync = true
        _publishedVersion = nil
        _enableSearch = true
        shouldPlaySounds = true
        shouldDownloadOrders = true
        useDeviceCamera = true
        
        saveToDefaults()
        NotificationCenter.default.post(name: resetNotification, object: self, userInfo: nil)
    }
    
    public func valueChanged(_ value: ConfigStoreValue? = nil) {
        NotificationCenter.default.post(name: changedNotification, object: self, userInfo: ["value": value as Any])
        saveToDefaults()
    }
}

private extension DefaultsConfigStore {
    private func purgeAllSettings() {
        for key in Keys.allCases {
            defaults.removeObject(forKey: key.rawValue)
        }
        defaults.synchronize()
    }
    
    private func registerInitialValues() {
        defaults.register(defaults: [
            Keys.shouldPlaySounds.rawValue: true,
            Keys.useDeviceCamera.rawValue: true,
            Keys.shouldDownloadOrders.rawValue: true,
            Keys.scanMode.rawValue: "entry",
            Keys.asyncModeEnabled.rawValue: false])
    }

    private func loadFromDefaults() {
        logger.debug("💾 Loading user defaults")
        _welcomeScreenIsConfirmed = defaults.bool(forKey: key(.welcomeScreenIsConfirmed))
        _apiBaseURL = defaults.url(forKey: key(.apiBaseURL))
        _deviceName = defaults.string(forKey: key(.deviceName))
        _organizerSlug = defaults.string(forKey: key(.organizerSlug))
        _deviceID = defaults.integer(forKey: key(.deviceID))
        _securityProfile = PXSecurityProfile(rawValue: defaults.string(forKey: key(.securityProfile)))
        _deviceUniqueSerial = defaults.string(forKey: key(.deviceUniqueSerial))
        _scanMode = defaults.string(forKey: key(.scanMode)) ?? "entry"
        _asyncModeEnabled = defaults.bool(forKey: key(.asyncModeEnabled))
        shouldPlaySounds = defaults.bool(forKey: key(.shouldPlaySounds))
        useDeviceCamera = defaults.value(forKey: key(.useDeviceCamera)) as? Bool ?? true
        shouldDownloadOrders = defaults.bool(forKey: key(.shouldDownloadOrders))
        _publishedVersion = defaults.string(forKey: key(.publishedSoftwareVersion))
        _enableSearch = defaults.value(forKey: key(.enableSearch)) as? Bool ?? true
        _shouldAutoSync = defaults.value(forKey: key(.shouldAutoSync)) as? Bool ?? true
        
        // Event
        if let eventData = defaults.data(forKey: key(.event)) {
            _event = try? jsonDecoder.decode(Event.self, from: eventData)
        }

        if let allManagedEventsData = defaults.data(forKey: key(.allManagedEvents)) {
            _allManagedEvents = (try? jsonDecoder.decode([Event].self, from: allManagedEventsData)) ?? []
        }

        // CheckInList
        if let checkinListData = defaults.data(forKey: key(.checkInList)) {
            _checkInList = try? jsonDecoder.decode(CheckInList.self, from: checkinListData)
        }

        // Retrieve API Token from KeyChain
        guard let apiBaseURL = _apiBaseURL?.absoluteString else { return }
        _apiToken = Keychain.get(account: apiBaseURL, service: apiBaseURL)
    }
    
    private func printDeviceIdentity() {
#if DEBUG
        // prints the device identity which can be looked up in the pretix.eu portal
        let did = _deviceID ?? -1
        let dsn = _deviceUniqueSerial ?? "-"
        logger.debug("🔑 device identity: \(String(did)), serial \(dsn)")
#endif
    }

    private func saveToDefaults() {
        logger.debug("💾 Saving user defaults")
        save(_welcomeScreenIsConfirmed, forKey: .welcomeScreenIsConfirmed)
        save(_apiBaseURL, forKey: .apiBaseURL)
        save(_deviceName, forKey: .deviceName)
        save(_organizerSlug, forKey: .organizerSlug)
        save(_deviceID, forKey: .deviceID)
        save(_securityProfile.rawValue, forKey: .securityProfile)
        save(_scanMode, forKey: .scanMode)
        save(_deviceUniqueSerial, forKey: .deviceUniqueSerial)
        save(_asyncModeEnabled, forKey: .asyncModeEnabled)
        save(_shouldAutoSync, forKey: .shouldAutoSync)
        save(try? jsonEncoder.encode(_event), forKey: .event)
        save(try? jsonEncoder.encode(_checkInList), forKey: .checkInList)
        save(try? jsonEncoder.encode(_allManagedEvents), forKey: .allManagedEvents)
        save(_publishedVersion, forKey: .publishedSoftwareVersion)
        save(_enableSearch, forKey: .enableSearch)
        
        defaults.synchronize()

        // Save api token into keychain
        guard let apiToken = _apiToken, let apiBaseURL = _apiBaseURL?.absoluteString else { return }
        Keychain.set(password: apiToken, account: apiBaseURL, service: apiBaseURL)
    }

    private func save(_ value: Bool?, forKey key: Keys) {
        if value == nil {
            defaults.removeObject(forKey: self.key(key))
        } else {
            defaults.set(value, forKey: self.key(key))
        }
    }

    private func save(_ value: URL?, forKey key: Keys) {
        if value == nil {
            defaults.removeObject(forKey: self.key(key))
        } else {
            defaults.set(value, forKey: self.key(key))
        }
    }

    private func save(_ value: String?, forKey key: Keys) {
        if value == nil {
            defaults.removeObject(forKey: self.key(key))
        } else {
            defaults.set(value, forKey: self.key(key))
        }
    }

    private func save(_ value: Int?, forKey key: Keys) {
        if value == nil {
            defaults.removeObject(forKey: self.key(key))
        } else {
            defaults.set(value, forKey: self.key(key))
        }
    }

    private func save(_ value: Data?, forKey key: Keys) {
        if value == nil {
            defaults.removeObject(forKey: self.key(key))
        } else {
            defaults.set(value, forKey: self.key(key))
        }
    }

    private func key(_ key: Keys) -> String {
        let prefix = (Bundle.main.bundleIdentifier ?? "") + "."
        return prefix + key.rawValue
    }
}
