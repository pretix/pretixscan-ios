//
//  DataStore.swift
//  PretixScan
//
//  Created by Daniel Jilg on 08.04.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

/// Stores large amounts of relational data
///
/// - Note: All `store*` methods will completely overwrite all existing data, without any merging. This is because we expect data to
///         always come from the server, which has the canonical truth.
///         For performance reasons, implementations might do a comparison first and not update unchanged items.
public protocol DataStore: class {
    // MARK: Metadata
    /// Store timestamps of the last syncs
    func storeLastSynced(_ data: [String: String])

    /// Retrieve timestamps of the last syncs
    func retrieveLastSynced() -> [String: String]

    // MARK: - Storing
    /// Store a list of `Model`s related to an `Event`
    func store<T: Model>(_ resources: [T], for event: Event)

    // MARK: - Retrieving
    // Retrieve all Events for the current user
    func getEvents() -> [Event]

    // Retrieve all Check-In Lists for the current user and event
    func getCheckInLists(for event: Event) -> [CheckInList]
}
