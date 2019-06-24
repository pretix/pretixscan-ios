//
//  MultiLingualString.swift
//  PretixScan
//
//  Created by Daniel Jilg on 15.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

/// A key for `MultiLingualString`
public enum LanguageCode: String {
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
    public static func english(_ newStringValue: String) -> MultiLingualString {
        var newMultiLingualString = MultiLingualString()
        newMultiLingualString[LanguageCode.english.rawValue] = newStringValue
        return newMultiLingualString
    }

    /// Create a new `MultiLingualString` with the given value as german representation
    public static func german(_ newStringValue: String) -> MultiLingualString {
        var newMultiLingualString = MultiLingualString()
        newMultiLingualString[LanguageCode.german.rawValue] = newStringValue
        return newMultiLingualString
    }
}

// MARK: - Custom Getters and Setters
extension MultiLingualString {
    public var english: String? {
        get { return self[LanguageCode.english.rawValue] }
        set { self[LanguageCode.english.rawValue] = newValue }
    }

    public var german: String? {
        get { return self[LanguageCode.german.rawValue] }
        set { self[LanguageCode.german.rawValue] = newValue }
    }

    public var germanInformal: String? {
        get { return self[LanguageCode.germanInformal.rawValue] }
        set { self[LanguageCode.germanInformal.rawValue] = newValue }
    }

    public var dutch: String? {
        get { return self[LanguageCode.dutch.rawValue] }
        set { self[LanguageCode.dutch.rawValue] = newValue }
    }

    public var dutchInformal: String? {
        get { return self[LanguageCode.dutchInformal.rawValue] }
        set { self[LanguageCode.dutchInformal.rawValue] = newValue }
    }

    public var spanish: String? {
        get { return self[LanguageCode.spanish.rawValue] }
        set { self[LanguageCode.spanish.rawValue] = newValue }
    }

    public var french: String? {
        get { return self[LanguageCode.french.rawValue] }
        set { self[LanguageCode.french.rawValue] = newValue }
    }

    public var turkish: String? {
        get { return self[LanguageCode.turkish.rawValue] }
        set { self[LanguageCode.turkish.rawValue] = newValue }
    }
}

// MARK: - Getting a String Representation
/// A String equal that contains various translations.
///
/// Use the `representation(in:)` methods to retrieve a specific representation or use `anyRepresentation()` to
/// get a representation that will prioritize english, then german, then other languages.
extension MultiLingualString {
    /// Return a representation of the string with the given locale
    public func representation(in locale: Locale?) -> String? {
        guard let languageCode = locale?.languageCode else { return anyRepresentation() }
        return representation(in: languageCode)
    }

    /// Return a representation of the string with the region code as `MultiLingualStringLanguage`.
    public func representation(in languageCode: LanguageCode) -> String? {
        return representation(in: languageCode.rawValue)
    }

    /// Return a representation of the string with the given ISO639-2 code
    public func representation(in languageCode: String) -> String? {
        if let representation = self[languageCode],
            representation.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count > 0 {
            return representation
        }

        if let representation = self["\(languageCode)-informal"],
            representation.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count > 0 {
            return representation
        }

        return anyRepresentation()
    }

    /// Return a string representation of the MultiLingual String, if any such exists at all
    ///
    /// Will try known languages first, then pick any other languages. Will only return `nil`
    /// if not a single language is saved inside the MultiLingualString.
    public func anyRepresentation() -> String? {
        let languageCodes: [LanguageCode] = [.english, .german, .germanInformal, .spanish,
                                                            .french, .dutch, .dutchInformal, .turkish]
        for languageCode in languageCodes {
            if let representation = self[languageCode.rawValue],
                representation.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count > 0 {
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
