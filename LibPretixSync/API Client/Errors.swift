//
//  Errors.swift
//  PretixScan
//
//  Created by Daniel Jilg on 14.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

enum APIErrors: Error {
    case notConfigured(message: String)
    case emptyResponse
    case nonHTTPResponse
    case unauthorized
    case forbidden
    case unknownStatusCode(statusCode: Int)
    case couldNotCreateURL
}
