//
//  Errors.swift
//  PretixScan
//
//  Created by Daniel Jilg on 14.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

struct Errors {
    struct EmptyResponse: Error {
        var localizedDescription: String = "The server response was empty"
    }

    struct NonHTTPResponse: Error {
        var localizedDescription: String = "The server response was not a HTTP Response"
    }

    struct Unauthorized: Error {
        var localizedDescription: String = "Authentication failure"
    }

    struct Forbidden: Error {
        var localizedDescription: String = "The requested organizer does not exist or you have no permission to view it."
    }

    struct UnknownStatusCode: Error {
        var localizedDescription: String = "The Server returned an unexpected Status Code"
    }
}
