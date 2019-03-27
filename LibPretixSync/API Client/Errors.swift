//
//  Errors.swift
//  PretixScan
//
//  Created by Daniel Jilg on 14.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

enum APIError: Error {
    case notConfigured(message: String)
    case emptyResponse
    case nonHTTPResponse
    case badRequest // 400
    case unauthorized // 401
    case forbidden // 403
    case notFound // 404
    case unknownStatusCode(statusCode: Int)
    case couldNotCreateURL
    case couldNotCreateNonce
    case couldNotParseJSON
}
