//
//  Errors.swift
//  PretixScan
//
//  Created by Daniel Jilg on 14.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

enum APIError: Error {
    case initializationError(message: String)
    case notConfigured(message: String)
    case emptyResponse
    case nonHTTPResponse
    case unchanged // 304
    case badRequest // 400
    case unauthorized // 401
    case forbidden // 403
    case notFound // 404
    case notAllowed // 405
    case retryAfter(seconds: Int) // 429
    case unknownStatusCode(statusCode: Int)
    case couldNotCreateURL
    case couldNotCreateNonce
    case fileNotFound
    case unknownFileType
    /// The device token has been explicitly revoked and can no longer be used.
    case accessRevoked
}


extension APIError {
    init?(from msg: ServerErrorMessage) {
        if msg.detail == "Device access has been revoked." {
            self = APIError.accessRevoked
            return
        }

        return nil
    }
}

extension Error {
    /// Errors that arise from the network transport or from the pretix API's responses
    /// These reflect connectivity or expected workflows so they're just logged locally
    var isOperationalError: Bool {
        if self is URLError { return true }
        guard let apiError = self as? APIError else { return false }
        switch apiError {
        case .unchanged, .badRequest, .unauthorized, .forbidden, .notFound,
             .notAllowed, .retryAfter, .unknownStatusCode, .accessRevoked:
            return true
        case .initializationError, .notConfigured, .emptyResponse, .nonHTTPResponse,
             .couldNotCreateURL, .couldNotCreateNonce, .fileNotFound, .unknownFileType:
            return false
        }
    }
}
