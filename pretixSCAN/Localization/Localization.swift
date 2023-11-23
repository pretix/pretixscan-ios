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

    struct TicketStatus {
        static let CanceledTicket = NSLocalizedString("Canceled", comment: "")
        static let UnpaidTicket = NSLocalizedString("Unpaid", comment: "")
        static let ValidTicket = NSLocalizedString("Valid Ticket", comment: "")
        static let Valid = NSLocalizedString("Valid", comment: "")
        static let Redeemed = NSLocalizedString("Redeemed", comment: "")
        static let ValidExit = NSLocalizedString("Exit stored", comment: "")
        static let TicketAlreadyRedeemed = NSLocalizedString("Ticket Already Used", comment: "")
        static let InvalidTicket = NSLocalizedString("Invalid Ticket", comment: "")
        static let Error = NSLocalizedString("Error", comment: "")
        static let NeedsAttention = NSLocalizedString("Valid Ticket, but needs attention", comment: "")
        static let UnpaidContinueButtonTitle = NSLocalizedString("Check In Unpaid", comment: "")
        static let TicketRequiresAttention = NSLocalizedString("Attention, special ticket!", comment: "")
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
        static let ResetDevice = NSLocalizedString("Reset Device", comment: "")
        static let NoEventsToShowError = NSLocalizedString("There are no events to show", comment: "")
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

    struct SearchHeaderView {
        static let NotEnoughCharacters = NSLocalizedString("Search will begin after you have typed at least 3 characters.", comment: "")
        static let Loading = NSLocalizedString("Loading Search", comment: "")
        static let NoResults = NSLocalizedString("Found No Results", comment: "")
        static let OneResult = NSLocalizedString("Found one Result", comment: "")
        static let NResults = NSLocalizedString("Found %d Results", comment: "Placeholder is an integer")
        static let TooManyResults = NSLocalizedString("Found too many results, keep typing", comment: "")
    }

    struct CheckInStatusTableViewController {
        static let Title = NSLocalizedString("Statistics", comment: "")
    }

    struct CheckInStatusOverviewTableViewCell {
        static let CheckInCountTitle = NSLocalizedString("Already Scanned", comment: "")
        static let PositionCountTitle = NSLocalizedString("Total Tickets Sold", comment: "")
        static let InsideCountTitle = NSLocalizedString("Currently Attending", comment: "")
    }

    struct SettingsTableViewController {
        static let Title = NSLocalizedString("Settings", comment: "")
        static let AboutSectionTitle = NSLocalizedString("About this App", comment: "")
        static let ConfigurationSectionTitle = NSLocalizedString("Configuration", comment: "")
        static let LicensesSectionTitle = NSLocalizedString("Libraries and Licenses", comment: "")
        static let UserInterfaceSectionTitle = NSLocalizedString("User interface", comment: "")
        static let ShouldAutoSync = NSLocalizedString("Sync every few minutes", comment: "")
        static let ScanMode = NSLocalizedString("Scan mode", comment: "")
        static let PlaySounds = NSLocalizedString("Play sounds", comment: "")
        static let UseCamera = NSLocalizedString("Use device camera", comment: "")
        static let ConnectExternalDevice = NSLocalizedString("ConnectExternalDevice", comment: "")
        static let Exit = NSLocalizedString("Exit", comment: "")
        static let Entry = NSLocalizedString("Entry", comment: "")
        static let BeginSyncing = NSLocalizedString("Sync Now", comment: "")
        static let ForceSync = NSLocalizedString("Force Complete Resync", comment: "")
        static let Version = NSLocalizedString("App Version", comment: "")
        static let Gate = NSLocalizedString("Gate", comment: "")
        static let PerformFactoryReset = NSLocalizedString("Reset Contents and Settings", comment: "")
        static let FactoryResetConfirmMessage = NSLocalizedString("This will delete event data from the device and log you out. Do you want to continue?", comment: "")
        static let CancelReset = NSLocalizedString("Do Nothing", comment: "")
        static let ConfirmReset = NSLocalizedString("Delete Everything", comment: "")
        static let SyncMode = NSLocalizedString("Sync Mode", comment: "")
        static let SyncModeExplanation = NSLocalizedString("In online mode, the app will confirm any check-ins in real-time with the server. In offline mode, the app will work locally and only synchronize it's data with the server every couple of minutes. When working with multiple devices, this can potentially mean that a ticket can be used multiple times. Choose offline mode if you have an unreliable internet connection but can tolerate such situations.", comment: "")
        static let SyncModeOnline = NSLocalizedString("Online", comment: "")
        static let SyncModeOffline = NSLocalizedString("Offline", comment: "")
        static let MITLicense = NSLocalizedString("MIT License", comment: "")
        static let DownloadOrders = NSLocalizedString("Download Orders", comment: "")
    }

    struct NotificationManager {
        static let SyncModeOnline = NSLocalizedString("Sync Mode Switched to Online", comment: "")
        static let SyncModeOffline = NSLocalizedString("Sync Mode Switched to Offline", comment: "")
        static let Reset = NSLocalizedString("All Contents and Settings were deleted", comment: "")
        static let ShouldAutoSyncOn = NSLocalizedString("Automatic Syncing is now enabled", comment: "")
        static let ShouldAutoSyncOff = NSLocalizedString("Automatic Syncing is now disabled", comment: "")
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
        static let RetryAfter = NSLocalizedString("The server is busy, please try again after @d seconds", comment: "")
        static let UnknownStatusCode = NSLocalizedString("The server returned an unkown status code: ", comment: "")
        static let CouldNotCreateURL = NSLocalizedString("Could not create URL", comment: "")
        static let CouldNotCreateNonce = NSLocalizedString("Could not create Nonce", comment: "")
        static let TicketNotFound = NSLocalizedString("This is not a ticket, or not a ticket for this event.", comment: "")
    }

    struct SyncStatusViewController {
        static let NeverSynced = NSLocalizedString("Last Sync: Never ", comment: "")
        static let SyncingDone = NSLocalizedString("Syncing Done ", comment: "")
        static let LessThanAMinute = NSLocalizedString("less than a minute", comment: "time interval")
        static let LastSyncXAgo = NSLocalizedString("Last Sync %@ ago ", comment: "e.g. Last Sync [12 minutes] ago")
    }

    struct QuestionsTableViewController {
        static let Title = NSLocalizedString("Questions", comment: "Title for the List of Questions")
        static let UploadNotPossibleNotice = NSLocalizedString("You need to upload a file here. Please do so from your computer", comment: "")
        static let TakePhotoAction = NSLocalizedString("Take a photo", comment: "")
    }

    struct QuestionCells {
        static let booleanYes = NSLocalizedString("Yes", comment: "Answer to a Boolean Check In Question")
        static let booleanNo = NSLocalizedString("No", comment: "Answer to a Boolean Check In Question")
        static let requiredBooleanQuestion = NSLocalizedString("You have to answer YES to check in", comment: "Note for a required boolean question")
    }
    
    struct Common {
        static let dismiss = NSLocalizedString("Dismiss", comment: "")
    }
}
