//
//  DefaultsConfigStore.swift
//  PretixScan
//
//  Created by Daniel Jilg on 03.04.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

/// ConfigStore implementation that stores configuration in UserDefaults.
///
/// Saving occurs automatically each time a property is set.
///
/// Loading occurs at init time. You can also load manually by calling `loadFromDefaults()`.
public class DefaultsConfigStore: ConfigStore {
    private var defaults: UserDefaults

    private enum Keys: String {
        case welcomeScreenIsConfirmed
        case apiBaseURL
        case apiToken
        case apiClient
        case deviceName
        case organizerSlug
        case deviceID
        case deviceUniqueSerial
        case event
        case checkInList
        case asyncModeEnabled
    }

    public var welcomeScreenIsConfirmed: Bool {
        get {
            return _welcomeScreenIsConfirmed
        }
        set {
            _welcomeScreenIsConfirmed = newValue
            valueChanged()
        }
    }

    public var apiBaseURL: URL? {
        get {
            return _apiBaseURL
        }
        set {
            _apiBaseURL = newValue
            valueChanged()
        }
    }

    public var apiToken: String? {
        get {
            return _apiToken
        }
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

    public var syncManager: SyncManager {
        _syncManager = _syncManager ?? SyncManager(configStore: self)
        return _syncManager!
    }

    public var dataStore: DataStore? {
        _dataStore = _dataStore ?? InMemoryDataStore()
        return _dataStore
    }

    public var deviceName: String? {
        get {
            return _deviceName
        }
        set {
            _deviceName = newValue
            valueChanged()
        }
    }

    public var organizerSlug: String? {
        get {
            return _organizerSlug
        }
        set {
            _organizerSlug = newValue
            valueChanged(.organizerSlug)
        }
    }

    public var deviceID: Int? {
        get {
            return _deviceID
        }
        set {
            _deviceID = newValue
            valueChanged()
        }
    }

    public var deviceUniqueSerial: String? {
        get {
            return _deviceUniqueSerial
        }
        set {
            _deviceUniqueSerial = newValue
            valueChanged()
        }
    }

    public private(set) var event: Event? {
        get {
            return _event
        }
        set {
            _event = newValue
            valueChanged(.event)
        }
    }

    public private(set) var checkInList: CheckInList? {
        get {
            return _checkInList
        }
        set {
            _checkInList = newValue
            valueChanged(.checkInList)
        }
    }

    public func set(event: Event, checkInList: CheckInList) {
        self.event = event
        self.checkInList = checkInList
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

    private var _welcomeScreenIsConfirmed: Bool = false
    private var _apiBaseURL: URL?
    private var _apiToken: String?
    private var _apiClient: APIClient?
    private var _offlineTicketValidator: OfflineTicketValidator?
    private var _onlineTicketValidator: OnlineTicketValidator?
    private var _syncManager: SyncManager?
    private var _dataStore: DataStore?
    private var _deviceName: String?
    private var _organizerSlug: String?
    private var _deviceID: Int?
    private var _deviceUniqueSerial: String?
    private var _event: Event?
    private var _checkInList: CheckInList?
    private var _asyncModeEnabled: Bool = false

    private let jsonEncoder = JSONEncoder.iso8601withFractionsEncoder
    private let jsonDecoder = JSONDecoder.iso8601withFractionsDecoder

    init(defaults: UserDefaults) {
        self.defaults = defaults
        loadFromDefaults()
    }

    private func valueChanged(_ value: ConfigStoreValue? = nil) {
        NotificationCenter.default.post(name: changedNotification, object: self, userInfo: ["value": value as Any])
        saveToDefaults()
    }

    public func factoryReset() {
        _welcomeScreenIsConfirmed = false
        _apiBaseURL = nil
        _apiToken = nil
        _apiClient = nil
        _deviceName = nil
        _organizerSlug = nil
        _deviceID = nil
        _deviceUniqueSerial = nil
        _event = nil
        _checkInList = nil
        _asyncModeEnabled = false

        saveToDefaults()
        NotificationCenter.default.post(name: resetNotification, object: self, userInfo: nil)
    }

    func loadFromDefaults() {
        _welcomeScreenIsConfirmed = defaults.bool(forKey: key(.welcomeScreenIsConfirmed))
        _apiBaseURL = defaults.url(forKey: key(.apiBaseURL))
        _apiToken = defaults.string(forKey: key(.apiToken))
        _deviceName = defaults.string(forKey: key(.deviceName))
        _organizerSlug = defaults.string(forKey: key(.organizerSlug))
        _deviceID = defaults.integer(forKey: key(.deviceID))
        _deviceUniqueSerial = defaults.string(forKey: key(.deviceUniqueSerial))
        _asyncModeEnabled = defaults.bool(forKey: key(.asyncModeEnabled))

        // Event
        if let eventData = defaults.data(forKey: key(.event)) {
            _event = try? jsonDecoder.decode(Event.self, from: eventData)
        }

        // CheckInList
        if let checkinListData = defaults.data(forKey: key(.checkInList)) {
            _checkInList = try? jsonDecoder.decode(CheckInList.self, from: checkinListData)
        }

        // APIClient should auto-initialize once the other values are given
    }

    func saveToDefaults() {
        save(_welcomeScreenIsConfirmed, forKey: .welcomeScreenIsConfirmed)
        save(_apiBaseURL, forKey: .apiBaseURL)
        save(_apiToken, forKey: .apiToken)
        save(_deviceName, forKey: .deviceName)
        save(_organizerSlug, forKey: .organizerSlug)
        save(_deviceID, forKey: .deviceID)
        save(_deviceUniqueSerial, forKey: .deviceUniqueSerial)
        save(_asyncModeEnabled, forKey: .asyncModeEnabled)
        save(try? jsonEncoder.encode(_event), forKey: .event)
        save(try? jsonEncoder.encode(_checkInList), forKey: .checkInList)

        defaults.synchronize()
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
