//
//  MultiLingualString.swift
//  PretixScan
//
//  Created by Daniel Jilg on 15.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

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

extension MultiLingualString: CustomStringConvertible {
    public var description: String {
        let allLanguages = [english, german, germanInformal, spanish, french, dutch, dutchInformal, turkish]
        for language in allLanguages where language != nil {
            return language!
        }

        return "(no value)"
    }
}
