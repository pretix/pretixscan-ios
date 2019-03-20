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
    public var isAPIConfigured: Bool { return apiBaseURL != nil && apiToken != nil }
    public var apiBaseURL: URL? { didSet { valueChanged() } }
    public var apiToken: String? { didSet { valueChanged() } }
    public var apiClient: APIClient? {
        storedAPIClient = storedAPIClient ?? APIClient(configStore: self)
        return storedAPIClient
    }
    private var storedAPIClient: APIClient?

    // MARK: - Device
    public var deviceName: String? { didSet { valueChanged() } }
    public var organizerSlug: String? { didSet { valueChanged() } }
    public var deviceID: Int? { didSet { valueChanged() } }
    public var deviceUniqueSerial: String? { didSet { valueChanged() } }

    // MARK: - Current Event and Check-In List
    public var event: Event? {
        didSet {
            // If the event changes, the check in list is invalid
            checkInList = nil
            valueChanged()
        }
    }
    public var checkInList: CheckInList? { didSet { valueChanged() } }

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

    private func valueChanged() {
        NotificationCenter.default.post(name: changedNotification, object: self, userInfo: nil)
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
        desc.append("isAPIConfigured:          \(isAPIConfigured)\n")
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
