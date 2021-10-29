//
//  UnknownCaseProtocol.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 29/10/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation

/// Enums adobting the `UnknownCase` protocol will allow serialization to continue even when unknown values are encountered
public protocol UnknownCase: RawRepresentable, CaseIterable where RawValue: Equatable & Encodable & Decodable {
    static var unknownCase: Self { get }
}

public extension UnknownCase {
    init(rawValue: RawValue) {
        let value = Self.allCases.first { $0.rawValue == rawValue }
        self = value ?? Self.unknownCase
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(RawValue.self)
        let value = Self(rawValue: rawValue)
        self = value ?? Self.unknownCase
    }
}
