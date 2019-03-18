//
//  Localization.swift
//  PretixScan
//
//  Created by Daniel Jilg on 13.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

// swiftlint:disable line_length
import Foundation

struct Localization {
    struct WelcomeViewController {
        static let Title = NSLocalizedString("Welcome to PretixScan", comment: "")
        static let Explanation = NSLocalizedString("PretixScan is an event entry app that you can use to validate tickets that you sold throught pretix.", comment: "")
        static let CheckMarkDetail = NSLocalizedString("I understand that personal data of attendees of my connected events will be stored on this device and I will secure the device properly.", comment: "")
        static let Continue = NSLocalizedString("Continue", comment: "")
    }

    struct ConnectDeviceViewController {
        static let Title = NSLocalizedString("Connect Device", comment: "")
        static let Explanation = NSLocalizedString("To get started, create a new device in the Devices section of your organizer account in the pretix backend. You will then be presented with a configuration QR code to scan.", comment: "")
        static let ManualSetup = NSLocalizedString("Manual Setup", comment: "")

        static let ManualSetupTitle = NSLocalizedString("Enter Connection Details", comment: "")
        static let ManualSetupMessage = NSLocalizedString("Instead of scanning a QR code, you can read these details off your screen.", comment: "")
        static let URL = NSLocalizedString("System URL", comment: "")
        static let Token = NSLocalizedString("Token", comment: "")

        static let Connect = NSLocalizedString("Connect", comment: "")
        static let Cancel = NSLocalizedString("Cancel", comment: "")
    }

    struct SelectEventTableViewController {
        static let Title = NSLocalizedString("Select Event", comment: "")
    }
}
