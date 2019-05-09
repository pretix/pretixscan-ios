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
            case .initializationTokenAlreadyUsed:
                return Localization.Errors.InitializationTokenAlreadyUsed
            case .notConfigured(let message):
                return Localization.Errors.NotConfigured + message
            case .emptyResponse:
                return Localization.Errors.EmptyResponse
            case .nonHTTPResponse:
                return Localization.Errors.NonHTTPResponse
            case .badRequest:
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
            }
        } else {
            return self.localizedDescription
        }
    }
}
