//
//  ErrorMessage.swift
//  pretixSCAN
//
//  Created by Daniel Jilg on 09.05.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

extension Error {
    var localized: String {
        if let apiError = self as? APIError {
            switch apiError {
            case .initializationError(let message):
                return message
            case .notConfigured(let message):
                return Localization.Errors.NotConfigured + message
            case .emptyResponse:
                return Localization.Errors.EmptyResponse
            case .nonHTTPResponse:
                return Localization.Errors.NonHTTPResponse
            case .badRequest, .notAllowed, .fileNotFound, .unknownFileType:
                return Localization.Errors.BadRequest
            case .unauthorized:
                return Localization.Errors.Unauthorized
            case .forbidden:
                return Localization.Errors.Forbidden
            case .notFound:
                return Localization.Errors.NotFound
            case .unknownStatusCode(let statusCode):
                return Localization.Errors.UnknownStatusCode + "\(statusCode)"
            case .couldNotCreateURL:
                return Localization.Errors.CouldNotCreateURL
            case .couldNotCreateNonce:
                return Localization.Errors.CouldNotCreateNonce
            case .unchanged:
                return "unchanged"
            case .retryAfter(let seconds):
                return String(format: Localization.Errors.RetryAfter, seconds)
            case .accessRevoked:
                return "Device access has been revoked"
            }
        } else {
            return self.localizedDescription
        }
    }
}
