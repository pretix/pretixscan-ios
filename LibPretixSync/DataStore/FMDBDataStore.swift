//
//  FMDBDataStore.swift
//  PretixScan
//
//  Created by Daniel Jilg on 11.04.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation
import FMDB

/// DataStore that uses FMDB to store data inside a MySQL file
///
/// - Note: See `DataStore` for function level documentation.
public class FMDBDataStore: DataStore {
    // MARK: Metadata
    /// Remove all Sync Times and pretend nothing was ever synced
    public func invalidateLastSynced(in event: Event) {
        // TODO
    }

    /// Store timestamps of the last syncs
    public func setLastSyncTime<T>(_ dateString: String, of model: T.Type, in event: Event) where T: Model {
        // TODO
    }

    /// Retrieve timestamps of the last syncs
    public func lastSyncTime<T>(of model: T.Type, in event: Event) -> String? where T: Model {
        // TODO
        return nil
    }

    // MARK: - Storing
    /// Store a list of `Model`s related to an `Event`
    public func store<T>(_ resources: [T], for event: Event) where T: Model {
        // TODO
        let queue = databaseQueue(with: event)
    }

    // MARK: - Retrieving
    // Retrieve all Events for the current user
    public func getEvents() -> [Event] {
        // TODO
        return []
    }

    // Retrieve all Check-In Lists for the current user and event
    public func getCheckInLists(for event: Event) -> [CheckInList] {
        // TODO
        return []
    }

    // Return all `OrderPosition`s matching the given query
    public func searchOrderPositions(_ query: String, in event: Event) -> [OrderPosition] {
        // TODO
        return []
    }

    /// Check in an attendee, identified by their secret, into the currently configured CheckInList
    ///
    /// Will return `nil` if no orderposition with the specified secret is found
    ///
    /// - See `RedemptionResponse` for the response returned in the completion handler.
    public func redeem(secret: String, force: Bool, ignoreUnpaid: Bool, in event: Event, in checkInList: CheckInList)
        -> RedemptionResponse? {
        // TODO
        return nil
    }

    /// Return the number of QueuedRedemptionReqeusts in the DataStore
    public func numberOfRedemptionRequestsInQueue(in event: Event) -> Int {
        // TODO
        return 0
    }

    /// Return a `QueuedRedemptionRequest` instance that has not yet been uploaded to the server
    public func getRedemptionRequest(in event: Event) -> QueuedRedemptionRequest? {
        // TODO
        return nil
    }

    /// Remove a `QeuedRedemptionRequest` instance from the database
    public func delete(_ queuedRedemptionRequest: QueuedRedemptionRequest, in event: Event) {
        // TODO
    }

    private var currentDataBaseQueue: FMDatabaseQueue?
    private var currentDataBaseQueueEvent: Event?

    func databaseQueue(with event: Event) -> FMDatabaseQueue? {
        // If we're dealing with the same database as last time, keep it open
        if currentDataBaseQueueEvent == event, let queue = currentDataBaseQueue {
            return queue
        }

        // Otherwise, close it...
        currentDataBaseQueue?.close()

        // ... and open a new queue
        let fileURL = try? FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("\(event.slug).sqlite")
        let queue = FMDatabaseQueue(url: fileURL)

        // Configure the queue
        queue?.inDatabase { database in
            do {
                try database.executeUpdate(Event.createSQLQuery(), values: nil)
            } catch {
                print("db init failed: \(error.localizedDescription)")
            }
        }

        // Cache the queue for later usage
        currentDataBaseQueue = queue
        currentDataBaseQueueEvent = event

        return queue
    }
}
