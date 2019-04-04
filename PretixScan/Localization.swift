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
    struct ValidateTicketViewController {
        static let Title = NSLocalizedString("PretixScan", comment: "")
        static let NoEvent = NSLocalizedString("No Event", comment: "")
        static let SearchPlaceHolder = NSLocalizedString("Search", comment: "")
    }

    struct TicketStatusViewController {
        static let ValidTicket = NSLocalizedString("Valid Ticket", comment: "")
        static let TicketAlreadyRedeemed = NSLocalizedString("Ticket Already Used", comment: "")
        static let InvalidTicket = NSLocalizedString("Invalid Ticket", comment: "")
        static let IncompleteInformation = NSLocalizedString("Incomplete Information", comment: "")
    }

    struct WelcomeViewController {
        static let Title = NSLocalizedString("Welcome", comment: "")
        static let Explanation = NSLocalizedString("PretixScan is an event entry app that you can use to validate tickets that you sold through pretix.", comment: "")
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

    struct SelectCheckInListTableViewController {
        static let Title = NSLocalizedString("Select Check-In List", comment: "")
    }

    struct SetupFinishedViewController {
        static let Title = NSLocalizedString("Setup Complete", comment: "")
        static let Explanation = NSLocalizedString("You can now start scanning", comment: "")
        static let Dismiss = NSLocalizedString("Start Scanning", comment: "")
    }

    struct SearchOrderPositionsTableViewController {
        static let Title = NSLocalizedString("Search", comment: "")
    }

    struct SearchResultsTableViewCell {
        static let Redeemed = NSLocalizedString("Checked In", comment: "")
        static let Valid = NSLocalizedString("Valid", comment: "")
    }

    struct CheckInStatusTableViewController {
        static let Title = NSLocalizedString("Statistics", comment: "")
    }

    struct CheckInStatusOverviewTableViewCell {
        static let CheckInCountTitle = NSLocalizedString("Already Scanned", comment: "")
        static let PositionCountTitle = NSLocalizedString("Total Tickets Sold", comment: "")
    }

    struct SettingsTableViewController {
        static let Title = NSLocalizedString("Settings", comment: "")
        static let Version = NSLocalizedString("App Version", comment: "")
        static let Reset = NSLocalizedString("Reset Contents and Settings", comment: "")
        static let SyncMode = NSLocalizedString("Sync Mode", comment: "")
        static let SyncModeOnline = NSLocalizedString("Online", comment: "")
        static let SyncModeOffline = NSLocalizedString("Offline", comment: "")
    }
}
