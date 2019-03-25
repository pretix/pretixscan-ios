//
//  DateFormattingHelpers.swift
//  PretixScan
//
//  Created by Daniel Jilg on 25.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

// The default implementation of JSONEncoder.DateEncodingStrategy.iso8601 throws an
// when encountering fractional seconds in ISO 8601 compatible dates. This file
// contains helper extensions to provide our own implementation of ISO 8601 compatible
// date encoding and decoding facilities that allow fractional seconds. This is
// necessary because the Pretix API uses fractional seconds.
//
// Mucho obrigado to https://stackoverflow.com/a/46458771/54547

extension JSONDecoder.DateDecodingStrategy {
    static let iso8601withFractions = custom { decoder throws -> Date in
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        if let date = Formatter.iso8601.date(from: string) ?? Formatter.iso8601noFS.date(from: string) {
            return date
        }
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(string)")
    }
}

extension JSONEncoder.DateEncodingStrategy {
    static let iso8601withFractions = custom { date, encoder throws in
        var container = encoder.singleValueContainer()
        try container.encode(Formatter.iso8601.string(from: date))
    }
}

extension Formatter {
    static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    static let iso8601noFS = ISO8601DateFormatter()
}
