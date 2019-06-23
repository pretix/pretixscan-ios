//
//  MultiLingualString.swift
//  PretixScan
//
//  Created by Daniel Jilg on 15.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

/// A key for `MultiLingualString`
public enum MultiLingualStringLanguage: String {
    case english = "en"
    case german = "de"
    case germanInformal = "de-informal"
    case spanish = "es"
    case french = "fr"
    case dutch = "nl"
    case dutchInformal = "nl-informal"
    case turkish = "tr"
}

/// A String equal that contains various translations.
///
/// This entry is the type alias. See `MultiLingualString` for full documentation and methods.
///
/// @see `MultiLingualString`, `MultiLingualStringLanguage`
public typealias MultiLingualString = [String: String]

// MARK: - Creation
extension MultiLingualString {
    /// Create a new `MultiLingualString` with the given value as english representation
    static func english(_ newStringValue: String) -> MultiLingualString {
        var newMultiLingualString = MultiLingualString()
        newMultiLingualString[MultiLingualStringLanguage.english.rawValue] = newStringValue
        return newMultiLingualString
    }

    /// Create a new `MultiLingualString` with the given value as german representation
    static func german(_ newStringValue: String) -> MultiLingualString {
        var newMultiLingualString = MultiLingualString()
        newMultiLingualString[MultiLingualStringLanguage.german.rawValue] = newStringValue
        return newMultiLingualString
    }
}

// MARK: - Getting a String Representation
/// A String equal that contains various translations.
///
/// Use the `representation(in:)` methods to retrieve a specific representation or use `anyRepresentation()` to
/// get a representation that will prioritize english, then german, then other languages.
extension MultiLingualString {
    /// Return a representation of the string with the given locale
    public func representation(in locale: Foundation.Locale) -> String? {
        guard let regionCode = locale.regionCode else { return anyRepresentation() }
        return representation(in: regionCode)
    }

    /// Return a representation of the string with the region code as `MultiLingualStringLanguage`.
    public func representation(in regionCode: MultiLingualStringLanguage) -> String? {
        return representation(in: regionCode.rawValue)
    }

    /// Return a representation of the string with the given ISO639-2 code
    public func representation(in regionCode: String) -> String? {
        if let representation = self[regionCode] {
            return representation
        }

        if let representation = self["\(regionCode)-informal"] {
            return representation
        }

        return anyRepresentation()
    }

    /// Return a string representation of the MultiLingual String, if any such exists at all
    ///
    /// Will try known languages first, then pick any other languages. Will only return `nil`
    /// if not a single language is saved inside the MultiLingualString.
    public func anyRepresentation() -> String? {
        let languageCodes: [MultiLingualStringLanguage] = [.english, .german, .germanInformal, .spanish,
                                                            .french, .dutch, .dutchInformal, .turkish]
        for languageCode in languageCodes {
            if let representation = self[languageCode.rawValue] {
                return representation
            }
        }

        return self.first?.value
    }
}

// MARK: - Storing as JSON
public extension MultiLingualString {
    /// Returns the MultiLingualString's representation as a String containing JSON.
    ///
    /// You should use `JSONDecoder.iso8601withFractionsDecoder` to decode the string again.
    func toJSONString() -> String? {
        if let data = try? JSONEncoder.iso8601withFractionsEncoder.encode(self) {
            return String(data: data, encoding: .utf8)
        }

        return nil
    }
}
