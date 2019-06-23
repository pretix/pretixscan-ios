//
//  Locale.swift
//  PretixScan
//
//  Created by Daniel Jilg on 08.04.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

/// The country code for a `MultilingualString`
public enum RegionCode: String, Codable, Equatable {
    /// English
    case english = "en"

    /// German
    case german = "de"

    /// German Informal
    case germanInformal = "de-informal"

    /// Spanish
    case spanish = "es"

    /// French
    case french = "fr"

    /// Dutch Formal
    case dutch = "nl"

    /// Dutch Informal
    case dutchInformal = "nl-informal"

    /// Turkish
    case turkish = "tr"
}
