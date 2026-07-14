//
//  ReusableMediumPositionSelector.swift
//  PretixScan
//
//  Created by Konstantin Kostov on 15/07/2026.
//  Copyright © 2026 rami.io. All rights reserved.
//

import Foundation

/// Picks a single `OrderPosition` to redeem out of the positions linked to a scanned reusable medium.
///
/// Mirrors the position selection semantics of Android's `AsyncCheckProvider.filterPositions`.
enum ReusableMediumPositionSelection {
    /// A single position was selected for redemption. It may still fail downstream checks.
    case position(OrderPosition)
    /// More than one position is valid at `nowDate`, so the pick is ambiguous.
    case ambiguous
    /// More than one position is linked to the medium, none is currently valid, and `OrderPosition` is the
    /// nearest candidate (future first, else past). Redemption must be refused as invalid_time directly.
    case invalidTime(OrderPosition)
}

extension ReusableMediumPositionSelection: Equatable {
    static func == (lhs: ReusableMediumPositionSelection, rhs: ReusableMediumPositionSelection) -> Bool {
        switch (lhs, rhs) {
        case (.ambiguous, .ambiguous):
            return true
        case (.ambiguous, .position), (.ambiguous, .invalidTime):
            return false
        case (.position, .ambiguous), (.position, .invalidTime):
            return false
        case (.invalidTime, .ambiguous), (.invalidTime, .position):
            return false
        case (.position(let lhsPosition), .position(let rhsPosition)):
            return lhsPosition.identifier == rhsPosition.identifier
        case (.invalidTime(let lhsPosition), .invalidTime(let rhsPosition)):
            return lhsPosition.identifier == rhsPosition.identifier
        }
    }
}

enum ReusableMediumPositionSelector {
    /// Selects a position to redeem out of the positions linked to a medium.
    ///
    /// - Returns: `nil` if `positions` is empty.
    static func select(from positions: [OrderPosition], nowDate: Date = Date()) -> ReusableMediumPositionSelection? {
        guard !positions.isEmpty else { return nil }

        if positions.count == 1 {
            return .position(positions[0])
        }

        let currentlyValid = positions.filter { isValid(at: nowDate, position: $0) }
        if currentlyValid.count == 1 {
            return .position(currentlyValid[0])
        }
        if currentlyValid.count > 1 {
            return .ambiguous
        }

        if let nearestFuture = nearestFuturePosition(in: positions, nowDate: nowDate) {
            return .invalidTime(nearestFuture)
        }

        if let nearestPast = nearestPastPosition(in: positions, nowDate: nowDate) {
            return .invalidTime(nearestPast)
        }

        return .ambiguous
    }

    private static func isValid(at nowDate: Date, position: OrderPosition) -> Bool {
        let validFromOk = position.validFrom == nil || position.validFrom! < nowDate
        let validUntilOk = position.validUntil == nil || position.validUntil! > nowDate
        return validFromOk && validUntilOk
    }

    /// Returns the position with the earliest `validFrom` that still lies in the future.
    private static func nearestFuturePosition(in positions: [OrderPosition], nowDate: Date) -> OrderPosition? {
        var nearest: OrderPosition?
        for position in positions {
            guard let validFrom = position.validFrom, validFrom > nowDate else { continue }
            if nearest == nil || validFrom < nearest!.validFrom! {
                nearest = position
            }
        }
        return nearest
    }

    /// Returns the last already-expired position in `positions`, mirroring Android's tie-break.
    private static func nearestPastPosition(in positions: [OrderPosition], nowDate: Date) -> OrderPosition? {
        var nearest: OrderPosition?
        for position in positions {
            guard let validUntil = position.validUntil else { continue }
            if validUntil < nowDate {
                nearest = position
            } else if let nearestValidUntil = nearest?.validUntil, validUntil > nearestValidUntil {
                nearest = position
            }
        }
        return nearest
    }
}
