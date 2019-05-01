//
//  CryptoHelpers.swift
//  PretixScan
//
//  Created by Daniel Jilg on 25.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

struct NonceGenerator {
    static func nonce(lenght: Int = 64) -> String {
        return NSUUID().uuidString
    }
}
