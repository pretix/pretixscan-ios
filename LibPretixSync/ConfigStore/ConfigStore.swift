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
    // MARK: - Welcome Screen
    /// Returns `true` if the warning screen has been accepted by the user
    var welcomeScreenIsConfirmed: Bool { get set }

    // MARK: - API Configuration
    /// Returns `true` if the API connection parameters are configured correctly.
    var isAPIConfigured: Bool { get }

    /// The base URL for the API
    var apiBaseURL: URL? { get set }

    /// The access token for the API
    var apiToken: String? { get set }

    /// Creates or returns a single APIClient instance configured for this ConfigStore
    var apiClient: APIClient? { get }

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
    var event: Event? { get set }

    /// The CheckInList to scan against
    var checkInList: CheckInList? { get set }
}

extension ConfigStore {
    /// Notification that should be fired whenever a ConfigStore value changes
    var changedNotification: Notification.Name { return Notification.Name("ConfigStoreChanged") }
}
