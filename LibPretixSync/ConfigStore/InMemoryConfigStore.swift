//
//  DefaultsConfigStore.swift
//  PretixScan
//
//  Created by Daniel Jilg on 13.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

/// ConfigStore implementation that stores configuration in memory.
///
/// Set the `debug` flag to make it print out each change to the console.
public class InMemoryConfigStore: ConfigStore {
    // MARK: - Welcome Screen
    public var welcomeScreenIsConfirmed: Bool = false { didSet { valueChanged() } }

    // MARK: - API Configuration
    public var apiBaseURL: URL? { didSet { valueChanged() } }
    public var apiToken: String? { didSet { valueChanged(.apiToken) } }
    public var apiClient: APIClient? {
        storedAPIClient = storedAPIClient ?? APIClient(configStore: self)
        return storedAPIClient
    }
    private var storedAPIClient: APIClient?

    public var dataStore: DataStore? {
        storedDataStore = storedDataStore ?? FMDBDataStore()
        return storedDataStore
    }
    private var storedDataStore: DataStore?

    public var syncManager: SyncManager {
        storedSyncManager = storedSyncManager ?? SyncManager(configStore: self)
        return storedSyncManager!
    }
    private var storedSyncManager: SyncManager?

    // MARK: TicketValidator
    public var ticketValidator: TicketValidator? {
        if !asyncModeEnabled {
            // Online Mode
            storedOnlineTicketValidator = storedOnlineTicketValidator ?? OnlineTicketValidator(configStore: self)
            return storedOnlineTicketValidator
        } else {
            // Ofline mode
            storedOfflineTicketValidator = storedOfflineTicketValidator ?? OfflineTicketValidator(configStore: self)
            return storedOfflineTicketValidator
        }
    }
    private var storedOnlineTicketValidator: OnlineTicketValidator?
    private var storedOfflineTicketValidator: OfflineTicketValidator?

    // MARK: - Device
    public var deviceName: String? { didSet { valueChanged() } }
    public var organizerSlug: String? { didSet { valueChanged(.organizerSlug) } }
    public var deviceID: Int? { didSet { valueChanged() } }
    public var deviceUniqueSerial: String? { didSet { valueChanged() } }

    // MARK: - Current Event and Check-In List
    public var event: Event? {
        didSet {
            // If the event changes, the check in list is invalid
            checkInList = nil
            valueChanged(.event)
        }
    }
    public var checkInList: CheckInList? { didSet { valueChanged(.checkInList) } }
    public var asyncModeEnabled: Bool = false { didSet { valueChanged(.asyncModeEnabled) } }

    public func factoryReset() {
        welcomeScreenIsConfirmed = false
        apiBaseURL = nil
        apiToken = nil
        storedAPIClient = nil
        deviceName = nil
        organizerSlug = nil
        deviceID = nil
        deviceUniqueSerial = nil
        event = nil
        checkInList = nil
        asyncModeEnabled = false

        NotificationCenter.default.post(name: resetNotification, object: self, userInfo: nil)
    }

    // MARK: - Debugging
    public var debug: Bool = false {
        didSet {
            if debug {
                print("InMemoryConfigStore enabled printing out all state changes to the console.")
            } else {
                print("InMemoryConfigStore disabled printing out all state changes to the console.")
            }
            valueChanged()
        }
    }

    private func valueChanged(_ value: ConfigStoreValue? = nil) {
        NotificationCenter.default.post(name: changedNotification, object: self, userInfo: ["value": value as Any])
        if debug { print(self) }
    }
}

extension InMemoryConfigStore: CustomStringConvertible {
    public var description: String {
        var desc = ""
        desc.append("----------------------------------------\n")
        desc.append("InMemoryConfigStore\n")
        desc.append("----------------------------------------\n")
        desc.append("welcomeScreenIsConfirmed: \(welcomeScreenIsConfirmed)\n")
        desc.append("apiBaseURL:               \(String(describing: apiBaseURL))\n")
        desc.append("apiToken:                 \(apiToken ?? "nil")\n")
        desc.append("deviceName:               \(deviceName ?? "nil")\n")
        desc.append("organizerSlug:            \(organizerSlug ?? "nil")\n")
        desc.append("deviceID:                 \(String(describing: deviceID))\n")
        desc.append("deviceUniqueSerial:       \(deviceUniqueSerial ?? "nil")\n")
        desc.append("event:                    \(String(describing: event))\n")
        desc.append("checkInList:              \(String(describing: checkInList))\n")
        desc.append("----------------------------------------\n")

        return desc
    }
}
