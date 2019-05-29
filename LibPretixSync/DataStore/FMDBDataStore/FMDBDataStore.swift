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
        guard let queue = databaseQueue(with: event) else {
            fatalError("Could not create database queue")
        }

        // Drop and recreate all tables to thoroughly clean the db
        // This includes the SyncTimestamp table
        queue.inDatabase { database in
            do {
                try database.executeUpdate(ItemCategory.destructionQuery, values: nil)
                try database.executeUpdate(Item.destructionQuery, values: nil)
                try database.executeUpdate(SubEvent.destructionQuery, values: nil)
                try database.executeUpdate(Order.destructionQuery, values: nil)
                try database.executeUpdate(OrderPosition.destructionQuery, values: nil)
                try database.executeUpdate(CheckIn.destructionQuery, values: nil)
                try database.executeUpdate(QueuedRedemptionRequest.destructionQuery, values: nil)
                try database.executeUpdate(SyncTimeStamp.destructionQuery, values: nil)
            } catch {
                print("db init failed: \(error.localizedDescription)")
            }
        }

        // Recreate the database
        _ = databaseQueue(with: event, recreate: true)
    }

    /// Store timestamps of the last syncs
    public func setLastSyncTime<T>(_ dateString: String, of model: T.Type, in event: Event) where T: Model {
        guard let queue = databaseQueue(with: event) else {
            fatalError("Could not create database queue")
        }

        queue.inDatabase { database in
            do {
                try database.executeUpdate(SyncTimeStamp.insertQuery, values: [model.stringName, dateString])
            } catch {
                print(error)
            }
        }
    }

    /// Retrieve timestamps of the last syncs
    public func lastSyncTime<T>(of model: T.Type, in event: Event) -> String? where T: Model {
        guard let queue = databaseQueue(with: event) else {
            fatalError("Could not create database queue")
        }

        var lastSyncedAt: String?
        queue.inDatabase { database in
            if let result = try? database.executeQuery(SyncTimeStamp.getSingleModelQuery, values: [model.stringName]) {
                while result.next() {
                    lastSyncedAt = result.string(forColumn: "last_synced_at")
                }
            }
        }

        if lastSyncedAt?.count == 0 {
            return nil
        }

        return lastSyncedAt
    }

    // MARK: - Storing
    /// Store a list of `Model`s related to an `Event`
    public func store<T>(_ resources: [T], for event: Event) where T: Model {
        guard let queue = databaseQueue(with: event) else {
            fatalError("Could not create database queue")
        }

        if let items = resources as? [Item] {
            Item.store(items, in: queue)
            return
        }

        if let itemCategories = resources as? [ItemCategory] {
            ItemCategory.store(itemCategories, in: queue)
            return
        }

        if let subEvents = resources as? [SubEvent] {
            SubEvent.store(subEvents, in: queue)
            return
        }

        if let orders = resources as? [Order] {
            Order.store(orders, in: queue)
            return
        }

        if let orderPositions = resources as? [OrderPosition] {
            OrderPosition.store(orderPositions, in: queue)
            return
        }

        if let queuedRedemptionRequests = resources as? [QueuedRedemptionRequest] {
            QueuedRedemptionRequest.store(queuedRedemptionRequests, in: queue)
            return
        }

        print("Don't know how to store \(T.humanReadableName)")
    }

    // MARK: - Retrieving
    // Return all `OrderPosition`s matching the given query
    public func searchOrderPositions(_ query: String, in event: Event) -> [OrderPosition] {
        guard let queue = databaseQueue(with: event) else {
            fatalError("Could not create database queue")
        }

        let queryPlaceholder = "\"%\(query.trimmingCharacters(in: .whitespacesAndNewlines))%\""
        let fullQuery = OrderPosition.searchQuery.replacingOccurrences(of: "?", with: queryPlaceholder)

        var searchResults = [OrderPosition]()
        queue.inDatabase { database in
            if let result = try? database.executeQuery(fullQuery, values: []) {
                while result.next() {
                    if let nextResult = OrderPosition.from(result: result) {
                        searchResults.append(nextResult)
                    }
                }
            }
        }

        // Populate with checkIns
        var foundOrderPositions = [OrderPosition]()
        for orderPosition in searchResults {
            let populatedOrderPosition = orderPosition.adding(checkIns: getCheckIns(for: orderPosition, in: event))
            foundOrderPositions.append(populatedOrderPosition)
        }

        return foundOrderPositions
    }

    private func getCheckIns(for orderPosition: OrderPosition, in event: Event) -> [CheckIn] {
        guard let queue = databaseQueue(with: event) else {
            fatalError("Could not create database queue")
        }

        var checkIns = [CheckIn]()
        queue.inDatabase { database in
            if let result = try? database.executeQuery(CheckIn.retrieveByOrderPositionQuery, values: [orderPosition.identifier]) {
                while result.next() {
                    if let nextCheckin = CheckIn.from(result: result, in: database) {
                        checkIns.append(nextCheckin)
                    }
                }
            }

        }

        return checkIns
    }

    public func getItem(by identifier: Identifier, in event: Event) -> Item? {
        guard let queue = databaseQueue(with: event) else {
            fatalError("Could not create database queue")
        }

        var item: Item?
        queue.inDatabase { database in
            if let result = try? database.executeQuery(Item.searchByIdentifierQuery, values: [identifier]) {
                while result.next() {
                    if let foundItem = Item.from(result: result, in: database) {
                        item = foundItem
                        return
                    }
                }
            }

        }

        return item
    }

    /// Check in an attendee, identified by their secret, into the currently configured CheckInList
    ///
    /// Will return `nil` if no orderposition with the specified secret is found
    public func redeem(secret: String, force: Bool, ignoreUnpaid: Bool, in event: Event, in checkInList: CheckInList)
        -> RedemptionResponse? {
            guard let queue = databaseQueue(with: event) else {
                fatalError("Could not create database queue")
            }

            guard let orderPosition = OrderPosition.get(secret: secret, in: queue) else {
                return nil
            }

            let checkIns = getCheckIns(for: orderPosition, in: event).filter {
                $0.listID == checkInList.identifier
            }

            let orderPositionWithCheckins = orderPosition.adding(checkIns: checkIns)

            // Check for previous check ins
            if checkIns.count > 0 {
                // Attendee is already checked in
                return RedemptionResponse(status: .error, errorReason: .alreadyRedeemed, position: orderPositionWithCheckins)
            }

            // Store a queued redemption request
            let checkInDate = Date()
            let redemptionRequest = RedemptionRequest(
                questionsSupported: false,
                date: checkInDate, force: force, ignoreUnpaid: ignoreUnpaid,
                nonce: NonceGenerator.nonce())
            let queuedRedemptionRequest = QueuedRedemptionRequest(
                redemptionRequest: redemptionRequest,
                eventSlug: event.slug,
                checkInListIdentifier: checkInList.identifier,
                secret: secret)

            QueuedRedemptionRequest.store([queuedRedemptionRequest], in: queue)

            // Save a check in to check the attendee in
            // This checkin will later be overwritten (or duplicated) by one synced down from the server
            let checkIn = CheckIn(listID: checkInList.identifier, date: checkInDate)
            CheckIn.store([checkIn], for: orderPositionWithCheckins, in: queue)

            // Return a positive redemption response
            return RedemptionResponse(status: .redeemed, errorReason: nil, position: orderPositionWithCheckins)
    }

    /// Return the number of QueuedRedemptionReqeusts in the DataStore
    public func numberOfRedemptionRequestsInQueue(in event: Event) -> Int {
        guard let queue = databaseQueue(with: event) else {
            fatalError("Could not create database queue")
        }

        var count = 0
        queue.inDatabase { database in
            if let result = try? database.executeQuery(QueuedRedemptionRequest.numberOfRequestsQuery, values: []) {
                while result.next() {
                    count = Int(result.int(forColumn: "COUNT(*)"))
                }
            }
        }

        return count
    }

    /// Return a `QueuedRedemptionRequest` instance that has not yet been uploaded to the server
    ///
    /// This implementation will deliberately return a random instance each time, in order to not block the upload queue with
    /// a malformed request forever.
    public func getRedemptionRequest(in event: Event) -> QueuedRedemptionRequest? {
        guard let queue = databaseQueue(with: event) else {
            fatalError("Could not create database queue")
        }

        var redemptionRequest: QueuedRedemptionRequest?
        queue.inDatabase { database in
            if let result = try? database.executeQuery(QueuedRedemptionRequest.retrieveOneRequestQuery, values: []) {
                while result.next() {
                    redemptionRequest = QueuedRedemptionRequest.from(result: result, in: database)
                }
            }
        }

        return redemptionRequest
    }

    /// Remove a `QeuedRedemptionRequest` instance from the database
    public func delete(_ queuedRedemptionRequest: QueuedRedemptionRequest, in event: Event) {
        guard let queue = databaseQueue(with: event) else {
            fatalError("Could not create database queue")
        }

        // Drop and recreate the sync times table
        queue.inDatabase { database in
            do {
                try database.executeUpdate(QueuedRedemptionRequest.deleteOneRequestQuery,
                    values: [queuedRedemptionRequest.redemptionRequest.nonce])
            } catch {
                print("db operation failed: \(error.localizedDescription)")
            }
        }
    }

    private var currentDataBaseQueue: FMDatabaseQueue?
    private var currentDataBaseQueueEvent: Event?

    func databaseQueue(with event: Event, recreate: Bool = false) -> FMDatabaseQueue? {
        // If we're dealing with the same database as last time, keep it open
        // except in case the caller specifically asked us to recreate the DB.
        if currentDataBaseQueueEvent == event, let queue = currentDataBaseQueue, !recreate {
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
                try database.executeUpdate(ItemCategory.creationQuery, values: nil)
                try database.executeUpdate(Item.creationQuery, values: nil)
                try database.executeUpdate(SubEvent.creationQuery, values: nil)
                try database.executeUpdate(Order.creationQuery, values: nil)
                try database.executeUpdate(OrderPosition.creationQuery, values: nil)
                try database.executeUpdate(CheckIn.creationQuery, values: nil)
                try database.executeUpdate(QueuedRedemptionRequest.creationQuery, values: nil)
                try database.executeUpdate(SyncTimeStamp.creationQuery, values: nil)
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
