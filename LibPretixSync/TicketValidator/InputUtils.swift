//
//  InputUtils.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 15/07/2026.
//  Copyright © 2026 rami.io. All rights reserved.
//

import Foundation

/// Cleans raw scanner input before it is used for ticket or medium lookups.
///
/// Mirrors libpretixsync's `InputUtils.cleanInput`.
enum InputUtils {
    private static let barcodeSourceType = "barcode"
    private static let replacementScalar: Unicode.Scalar = "\u{FFFD}"

    /// Removes unprintable/control characters, and for barcode input, strips ECI-flag prefixes
    /// prepended by some scanners and wallet apps (e.g. WalletPasses, Google Wallet) to QR payloads.
    /// https://en.wikipedia.org/wiki/Extended_Channel_Interpretation
    static func cleanInput(_ rawInput: String, sourceType: String = barcodeSourceType) -> String {
        let scalars = rawInput.unicodeScalars.map { scalar in
            isUnprintable(scalar) ? replacementScalar : scalar
        }
        var cleaned = String(String.UnicodeScalarView(scalars))

        if sourceType == barcodeSourceType {
            cleaned = removingPrefix("\\000001", from: cleaned) // Latin1
            cleaned = removingPrefix("\\000003", from: cleaned) // Latin1
            cleaned = removingPrefix("\\000026", from: cleaned) // UTF-8
            cleaned = removingPrefix("\\000027", from: cleaned) // ASCII
        }

        return cleaned
    }

    private static func isUnprintable(_ scalar: Unicode.Scalar) -> Bool {
        switch scalar.properties.generalCategory {
        case .control, .format, .surrogate, .privateUse, .unassigned:
            return true
        default:
            return false
        }
    }

    private static func removingPrefix(_ prefix: String, from string: String) -> String {
        guard string.hasPrefix(prefix) else { return string }
        return String(string.dropFirst(prefix.count))
    }
}
