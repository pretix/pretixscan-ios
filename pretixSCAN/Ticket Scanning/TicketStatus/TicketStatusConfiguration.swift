//
//  TicketStatusConfiguration.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 15/11/2023.
//  Copyright © 2023 rami.io. All rights reserved.
//

import Foundation

public struct TicketStatusConfiguration: Hashable, Equatable {
    var secret: String
    var force: Bool
    var ignoreUnpaid: Bool
    var answers: [Answer]?
}
