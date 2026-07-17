//
//  ReusableMediumPositionSelector.swift
//  PretixScan
//
//  Created by Konstantin Kostov on 15/07/2026.
//  Copyright © 2026 rami.io. All rights reserved.
//

import Foundation

/// Picks a single `OrderPosition` to redeem out of the positions linked to a scanned reusable medium
/// (server: api/views/checkin.py ~676-785).
enum ReusableMediumPositionSelection {
    /// A single position was selected for redemption. It may still fail downstream checks.
    case position(OrderPosition)
    /// Still ambiguous after filtering; carries the first original candidate (server: `op_candidates[0]`).
    case ambiguous(OrderPosition)
}

extension ReusableMediumPositionSelection: Equatable {
    static func == (lhs: ReusableMediumPositionSelection, rhs: ReusableMediumPositionSelection) -> Bool {
        switch (lhs, rhs) {
        case (.ambiguous(let lhsPosition), .ambiguous(let rhsPosition)):
            return lhsPosition.identifier == rhsPosition.identifier
        case (.ambiguous, .position), (.position, .ambiguous):
            return false
        case (.position(let lhsPosition), .position(let rhsPosition)):
            return lhsPosition.identifier == rhsPosition.identifier
        }
    }
}

enum ReusableMediumPositionSelector {
    /// Selects a position to redeem; `nil` if `positions` is empty.
    static func select(from positions: [OrderPosition], checkInList: CheckInList, nowDate: Date = Date()) -> ReusableMediumPositionSelection? {
        guard !positions.isEmpty else { return nil }

        if positions.count == 1 {
            return .position(positions[0])
        }

        // server step 3b: product filter
        var filtered = positions
        if filtered.count > 1 {
            filtered = filtered.filter { checkInList.allProducts || (checkInList.limitProducts?.contains($0.itemIdentifier) ?? false) }
        }

        // server step 3c: validity window filter, validFrom inclusive
        if filtered.count > 1 {
            filtered = filtered.filter { isValid(at: nowDate, position: $0) }
        }

        if filtered.count == 1 {
            return .position(filtered[0])
        }

        if filtered.isEmpty {
            // server fallback: nearest future, else latest past, else first
            if let nearestFuture = nearestFuturePosition(in: positions, nowDate: nowDate) {
                return .position(nearestFuture)
            }
            if let nearestPast = nearestPastPosition(in: positions, nowDate: nowDate) {
                return .position(nearestPast)
            }
            return .position(positions[0])
        }

        return .ambiguous(positions[0])
    }

    private static func isValid(at nowDate: Date, position: OrderPosition) -> Bool {
        let validFromOk = position.validFrom == nil || position.validFrom! <= nowDate
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

    /// Returns the latest already-expired position.
    private static func nearestPastPosition(in positions: [OrderPosition], nowDate: Date) -> OrderPosition? {
        var nearest: OrderPosition?
        for position in positions {
            guard let validUntil = position.validUntil else { continue }
            if validUntil < nowDate {
                if nearest == nil || validUntil > nearest!.validUntil! {
                    nearest = position
                }
            }
        }
        return nearest
    }
}
