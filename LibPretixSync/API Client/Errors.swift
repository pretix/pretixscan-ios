//
//  Errors.swift
//  PretixScan
//
//  Created by Daniel Jilg on 14.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

struct EmptyResponseError: Error {
    var localizedDescription: String = "The server response was empty"
}
