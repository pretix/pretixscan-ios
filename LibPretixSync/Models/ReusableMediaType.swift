//
//  ReusableMediaType.swift
//  PretixScan
//
//  Created by Konstantin Kostov on 15/07/2026.
//  Copyright © 2026 rami.io. All rights reserved.
//

import Foundation

/// The type of reusable medium an `Item` is configured to use, e.g. a barcode or an NFC tag.
public enum ReusableMediaType: String, Codable, UnknownCase {
    public static var unknownCase = ReusableMediaType.unsupported

    case none
    case barcode
    case nfcUid = "nfc_uid"
    case nfcMf0aes = "nfc_mf0aes"
    case unsupported
}
