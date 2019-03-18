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
public struct MultiLingualString: Codable, Equatable {
    public let english: String?
    public let german: String?
    public let germanInformal: String?
    public let spanish: String?
    public let french: String?
    public let dutch: String?
    public let dutchInformal: String?
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
    static func new(_ with: String) -> MultiLingualString {
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
}
