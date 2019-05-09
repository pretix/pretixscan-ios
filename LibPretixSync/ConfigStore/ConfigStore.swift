//
//  ConfigStore.swift
//  PretixScan
//
//  Created by Daniel Jilg on 13.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

/// A protocol that defines elements that contain information about the app's configuration.
public protocol ConfigStore {
    // MARK: - Configuration
    /// Restore all settings to factory default and start over. Returns the app into the state at first launch.
    func factoryReset()

    // MARK: - Configured Sub Systems
    /// Creates or returns a singleton APIClient instance configured for this ConfigStore
    var apiClient: APIClient? { get }

    /// Creates or returns a singleton TicketValidator instance configured for this ConfigStore
    ///
    /// The type of TicketValidator depends on the `asyncModeEnabled` property.
    var ticketValidator: TicketValidator? { get }

    /// Returns a singleton SyncManager instance configured for this ConfigStore
    var syncManager: SyncManager { get }

    /// Creates or returns a singleton DataStore instance configured for this ConfigStore
    var dataStore: DataStore? { get }

    // MARK: - Welcome Screen
    /// Returns `true` if the warning screen has been accepted by the user
    var welcomeScreenIsConfirmed: Bool { get set }

    // MARK: - API Configuration
    /// The base URL for the API
    var apiBaseURL: URL? { get set }

    /// The access token for the API
    var apiToken: String? { get set }

    /// If `true`, the app will use a local cache to redeem tickets. Will access the internet each time otherwise.
    ///
    /// Updates the `ticketValidator` property.
    var asyncModeEnabled: Bool { get set }

    // MARK: - Device
    /// The name that was specified for this device in the Pretix Organizer Backend
    var deviceName: String? { get set }

    /// The event organizer for this device
    var organizerSlug: String? { get set }

    /// The ID for this device as assigned by the API
    var deviceID: Int? { get set }

    /// The serial number for this device as assigned by the API
    var deviceUniqueSerial: String? { get set }

    // MARK: - Current Event and Check-In List
    /// The currently managed event
    var event: Event? { get }

    /// The CheckInList to scan against
    var checkInList: CheckInList? { get }

    // Set both event and checkinlist
    func set(event: Event, checkInList: CheckInList)
}

extension ConfigStore {
    /// Notification that should be fired whenever a ConfigStore value changes
    var changedNotification: Notification.Name { return Notification.Name("ConfigStoreChanged") }
    var resetNotification: Notification.Name { return Notification.Name("ConfigStoreFactoryReset") }
}

/// Value Keys to be used for notifications
public enum ConfigStoreValue: String {
    case apiToken
    case organizerSlug
    case event
    case checkInList
    case asyncModeEnabled
}
