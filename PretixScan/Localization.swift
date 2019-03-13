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
}
