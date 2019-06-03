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
        static let Title = NSLocalizedString("pretixSCAN", comment: "")
        static let NoEvent = NSLocalizedString("No Event", comment: "")
        static let SearchPlaceHolder = NSLocalizedString("Search", comment: "")
    }

    struct TicketStatusViewController {
        static let ValidTicket = NSLocalizedString("Valid Ticket", comment: "")
        static let TicketAlreadyRedeemed = NSLocalizedString("Ticket Already Used", comment: "")
        static let InvalidTicket = NSLocalizedString("Invalid Ticket", comment: "")
        static let Error = NSLocalizedString("Error", comment: "")
        static let IncompleteInformation = NSLocalizedString("Incomplete Information", comment: "")
        static let NeedsAttention = NSLocalizedString("Valid Ticket, but needs attention", comment: "")
        static let UnpaidContinueText = NSLocalizedString("This ticket has not been paid for, do you still want to check it in?", comment: "")
        static let UnpaidContinueButtonTitle = NSLocalizedString("Check In Unpaid", comment: "")
    }

    struct WelcomeViewController {
        static let Title = NSLocalizedString("Welcome", comment: "")
        static let Explanation = NSLocalizedString("pretixSCAN is an event entry app that you can use to validate tickets that you sold through pretix.", comment: "")
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
        static let AboutSectionTitle = NSLocalizedString("About this App", comment: "")
        static let ConfigurationSectionTitle = NSLocalizedString("Configuration", comment: "")
        static let LicensesSectionTitle = NSLocalizedString("Libraries and Licenses", comment: "")
        static let ShouldAutoSync = NSLocalizedString("Sync every few minutes", comment: "")
        static let BeginSyncing = NSLocalizedString("Sync Now", comment: "")
        static let ForceSync = NSLocalizedString("Force Complete Resync", comment: "")
        static let Version = NSLocalizedString("App Version", comment: "")
        static let PerformFactoryReset = NSLocalizedString("Reset Contents and Settings", comment: "")
        static let FactoryResetConfirmMessage = NSLocalizedString("This will delete event data from the device and log you out. Do you want to continue?", comment: "")
        static let CancelReset = NSLocalizedString("Do Nothing", comment: "")
        static let ConfirmReset = NSLocalizedString("Delete Everything", comment: "")
        static let SyncMode = NSLocalizedString("Sync Mode", comment: "")
        static let SyncModeOnline = NSLocalizedString("Online", comment: "")
        static let SyncModeOffline = NSLocalizedString("Offline", comment: "")
        static let MITLicense = NSLocalizedString("MIT License", comment: "")
    }

    struct NotificationManager {
        static let SyncModeOnline = NSLocalizedString("Sync Mode Switched to Online", comment: "")
        static let SyncModeOffline = NSLocalizedString("Sync Mode Switched to Offline", comment: "")
        static let Reset = NSLocalizedString("All Contents and Settings were deleted", comment: "")
    }

    struct Errors {
        static let Error = NSLocalizedString("Error", comment: "")
        static let Confirm = NSLocalizedString("OK", comment: "")

        static let InitializationError = NSLocalizedString("Initialization Token already used", comment: "")
        static let NotConfigured = NSLocalizedString("This feature cannot be used at the moment: ", comment: "")
        static let EmptyResponse = NSLocalizedString("The server returned an empty response", comment: "")
        static let NonHTTPResponse = NSLocalizedString("The server returned a non HTTP response", comment: "")
        static let BadRequest = NSLocalizedString("The server refused to handle our request", comment: "")
        static let Unauthorized = NSLocalizedString("You are not authorized to access this resource", comment: "")
        static let Forbidden = NSLocalizedString("You are forbidden from accessing this resource", comment: "")
        static let NotFound = NSLocalizedString("The resource was not found on the server", comment: "")
        static let UnknownStatusCode = NSLocalizedString("The server returned an unkown status code: ", comment: "")
        static let CouldNotCreateURL = NSLocalizedString("Could not create URL", comment: "")
        static let CouldNotCreateNonce = NSLocalizedString("Could not create Nonce", comment: "")
        static let TicketNotFound = NSLocalizedString("The ticket was not found for the current event", comment: "")
    }

    struct SyncStatusViewController {
        static let SyncingDone = NSLocalizedString("Syncing Done ", comment: "")
        static let LessThanAMinute = NSLocalizedString("less than a minute", comment: "time interval")
        static let LastSyncXAgo = NSLocalizedString("Last Sync %@ ago ", comment: "e.g. Last Sync [12 minutes] ago")
    }
}
