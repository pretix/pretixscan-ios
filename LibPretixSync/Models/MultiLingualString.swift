//
//  MultiLingualString.swift
//  PretixScan
//
//  Created by Daniel Jilg on 15.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

/// A String equal that contains various translations.
///
/// Use the `description` method to automatically return out a displayable string.
public struct MultiLingualString: Model {
    public static var humanReadableName = "Multi Lingual String"
    public static var stringName = ""

    /// English Representation
    public let english: String?

    /// German Representation
    public let german: String?

    /// German Informal Representation
    public let germanInformal: String?

    /// Spanish Representation
    public let spanish: String?

    /// French Representation
    public let french: String?

    /// Dutch Representation
    public let dutch: String?

    /// Dutch informal representation
    public let dutchInformal: String?

    /// Turkish Representation
    public let turkish: String?

    private enum CodingKeys: String, CodingKey {
        case english = "en"
        case german = "de"
        case germanInformal = "de-informal"
        case spanish = "es"
        case french = "fr"
        case dutch = "nl"
        case dutchInformal = "nl-informal"
        case turkish = "tr"
    }
}

// MARK: - CustomStringConvertible
extension MultiLingualString: CustomStringConvertible {
    public var description: String {
        let allLanguages = [english, german, germanInformal, spanish, french, dutch, dutchInformal, turkish]
        for language in allLanguages where language != nil {
            return language!
        }

        return "(no value)"
    }
}

// MARK: Easy creation
extension MultiLingualString {
    static func english(_ with: String) -> MultiLingualString {
        return MultiLingualString.init(
            english: with,
            german: nil,
            germanInformal: nil,
            spanish: nil,
            french: nil,
            dutch: nil,
            dutchInformal: nil,
            turkish: nil
        )
    }

    static func german(_ with: String) -> MultiLingualString {
        return MultiLingualString.init(
            english: nil,
            german: with,
            germanInformal: nil,
            spanish: nil,
            french: nil,
            dutch: nil,
            dutchInformal: nil,
            turkish: nil
        )
    }

    static func empty() -> MultiLingualString {
        return MultiLingualString.init(
            english: nil,
            german: nil,
            germanInformal: nil,
            spanish: nil,
            french: nil,
            dutch: nil,
            dutchInformal: nil,
            turkish: nil
        )
    }
}
