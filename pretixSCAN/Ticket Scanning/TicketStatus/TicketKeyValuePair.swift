//
//  TicketKeyValuePair.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 16/11/2023.
//  Copyright © 2023 rami.io. All rights reserved.
//

import Foundation

public struct TicketKeyValuePair: Codable, Hashable {
    let key: String
    let value: String
}
