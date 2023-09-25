//
//  TicketStatusExtraInformation.swift
//  TicketStatusExtraInformation
//
//  Created by Konstantin Kostov on 27/07/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation

enum TicketStatusExtraInformation {
    /// Additional notes to be shown
    case notes(values: [String])
    /// The ticket was validated using the offline ticket validator
    case offlineValidation(reason: TicketValidationReason)
    /// No extra information
    case none
}
