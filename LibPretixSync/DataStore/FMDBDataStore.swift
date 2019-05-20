//
//  FMDBDataStore.swift
//  PretixScan
//
//  Created by Daniel Jilg on 11.04.19.
//  Copyright © 2019 rami.io. All rights reserved.
//
// swiftlint:disable identifier_name

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
        guard let queue = databaseQueue(with: event) else {
            fatalError("Could not create database queue")
        }

        if let checkIns = resources as? [CheckIn] {
            store(checkIns, in: queue)
            return
        }

        if let items = resources as? [Item] {
            store(items, in: queue)
            return
        }

        // TODO: Store Item Categories
        // TODO: Store Sub Events
        // TODO: Store Quotas
        // TODO: Store OrderPositions

        // TODO: Store Events
        // TODO: Store Orders

        print("Don't know how to store \(T.humanReadableName)")
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
        print("Opening Database \(fileURL?.path ?? "ERROR")")
        let queue = FMDatabaseQueue(url: fileURL)

        // Configure the queue
        queue?.inDatabase { database in
            do {
                try database.executeUpdate(Event.creationQuery, values: nil)
                try database.executeUpdate(ItemCategory.creationQuery, values: nil)
                try database.executeUpdate(Item.destructionQuery, values: nil)
                try database.executeUpdate(Item.creationQuery, values: nil)
                try database.executeUpdate(SubEvent.creationQuery, values: nil)
                try database.executeUpdate(Order.creationQuery, values: nil)
                try database.executeUpdate(OrderPosition.creationQuery, values: nil)
                try database.executeUpdate(CheckIn.creationQuery, values: nil)

                // TODO: Create DB for Quotas
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

// MARK: - Storing
private extension FMDBDataStore {
    func store(_ checkIns: [CheckIn], in queue: FMDatabaseQueue) {
        // TODO: Store Checkins
    }

    func store(_ items: [Item], in queue: FMDatabaseQueue) {
        queue.inDatabase { database in
            for item in items {
                let identifier = item.identifier as Int
                let name = item.name.toJSONString()
                let internal_name = item.internalName
                let default_price = item.defaultPrice as String
                let category = item.categoryIdentifier as Int?
                let active = item.active.toInt()
                let description = item.description?.toJSONString()
                let position = item.position
                let checkin_attention = item.checkInAttention.toInt()
                let json = item.toJSONString()

                do {
                    try database.executeUpdate(Item.insertQuery, values: [
                        identifier, name as Any, internal_name as Any, default_price,
                        category as Any, active, description as Any,
                        position, checkin_attention, json as Any])
                } catch {
                    print(error)
                }
            }
        }
    }
}

fileprivate extension Bool {
    func toInt() -> Int {
        return self ? 1 : 0
    }
}

fileprivate extension Int {
    func toBool() -> Bool {
        return self > 0
    }
}

// MARK: Storing as String
fileprivate extension Model {
    func toJSONString() -> String? {
        if let data = try? JSONEncoder.iso8601withFractionsEncoder.encode(self) {
            return String(data: data, encoding: .utf8)
        }

        return nil
    }
}
