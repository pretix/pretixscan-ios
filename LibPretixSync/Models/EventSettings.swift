//
//  EventSettings.swift
//  PretixScan
//
//  Created by Konstantin Kostov on 15/07/2026.
//  Copyright © 2026 rami.io. All rights reserved.
//

import Foundation

/// Event-level settings synced from the server.
///
/// Source: https://docs.pretix.eu/en/latest/api/resources/events.html#event-settings
public struct EventSettings: Model {
    public static let humanReadableName = "Event Settings"
    public static let stringName = "settings"

    public let reusableMediaUsageEnforced: Bool

    private enum CodingKeys: String, CodingKey {
        case reusableMediaUsageEnforced = "reusable_media_usage_enforced"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        reusableMediaUsageEnforced = try container.decodeIfPresent(Bool.self, forKey: .reusableMediaUsageEnforced) ?? false
    }

    public init(reusableMediaUsageEnforced: Bool) {
        self.reusableMediaUsageEnforced = reusableMediaUsageEnforced
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(reusableMediaUsageEnforced, forKey: .reusableMediaUsageEnforced)
    }
}

extension EventSettings: Equatable {
    public static func == (lhs: EventSettings, rhs: EventSettings) -> Bool {
        return lhs.reusableMediaUsageEnforced == rhs.reusableMediaUsageEnforced
    }
}

extension EventSettings: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.reusableMediaUsageEnforced)
    }
}
