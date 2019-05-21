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
        guard let queue = databaseQueue(with: event) else {
            fatalError("Could not create database queue")
        }

        // Drop and recreate the sync times table
        queue.inDatabase { database in
            do {
                try database.executeUpdate(SyncTimeStamp.destructionQuery, values: nil)
                try database.executeUpdate(SyncTimeStamp.creationQuery, values: nil)
            } catch {
                print("db operation failed: \(error.localizedDescription)")
            }
        }
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
            store(items, in: queue)
            return
        }

        if let itemCategories = resources as? [ItemCategory] {
            store(itemCategories, in: queue)
            return
        }

        if let subEvents = resources as? [SubEvent] {
            store(subEvents, in: queue)
            return
        }

        if let orders = resources as? [Order] {
            store(orders, in: queue)
            return
        }

        if let orderPositions = resources as? [OrderPosition] {
            store(orderPositions, in: queue)
            return
        }

        if let queuedRedemptionRequests = resources as? [QueuedRedemptionRequest] {
            store(queuedRedemptionRequests, in: queue)
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

        var searchResults = [OrderPosition]()
        queue.inDatabase { database in
            if let result = try? database.executeQuery(QueuedRedemptionRequest.numberOfRequestsQuery, values: []) {
                while result.next() {
                    if let nextResult = OrderPosition.from(result: result) {
                        searchResults.append(nextResult)
                    }
                }
            }
        }

        // Todo: populate with checkIns

        return searchResults
    }

    private func getCheckIns(for orderPosition: OrderPosition) -> [CheckIn] {
        // TODO: implement
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
    public func getRedemptionRequest(in event: Event) -> QueuedRedemptionRequest? {
        guard let queue = databaseQueue(with: event) else {
            fatalError("Could not create database queue")
        }

        var redemptionRequest: QueuedRedemptionRequest?
        queue.inDatabase { database in
            if let result = try? database.executeQuery(QueuedRedemptionRequest.retrieveOneRequestQuery, values: []) {
                while result.next() {
                    redemptionRequest = QueuedRedemptionRequest.from(result: result)
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

// MARK: - Storing
private extension FMDBDataStore {
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

    func store(_ itemCategories: [ItemCategory], in queue: FMDatabaseQueue) {
        queue.inDatabase { database in
            for itemCategory in itemCategories {
                let identifier = itemCategory.identifier as Int
                let name = itemCategory.name.toJSONString()
                let internal_name = itemCategory.internalName
                let description = itemCategory.description?.toJSONString()
                let position = itemCategory.position
                let is_addon = itemCategory.isAddon

                do {
                    try database.executeUpdate(ItemCategory.insertQuery, values: [
                        identifier, name as Any, internal_name as Any, description as Any, position, is_addon])
                } catch {
                    print(error)
                }
            }
        }
    }

    func store(_ records: [SubEvent], in queue: FMDatabaseQueue) {
        queue.inDatabase { database in
            for record in records {
                let identifier = record.identifier as Int
                let name = record.name.toJSONString()
                let event = record.event
                let json = record.toJSONString()

                do {
                    try database.executeUpdate(SubEvent.insertQuery, values: [
                        identifier, name as Any, event, json as Any])
                } catch {
                    print(error)
                }
            }
        }
    }

    func store(_ records: [Order], in queue: FMDatabaseQueue) {
        for record in records {
            if let positions = record.positions {
                store(positions, in: queue)
            }

            queue.inDatabase { database in
                let code = record.code
                let status = record.status.rawValue
                let secret = record.secret
                let email = record.email
                let checkin_attention = record.checkInAttention?.toInt()
                let require_approval = record.requireApproval?.toInt()
                let json = record.toJSONString()

                do {
                    try database.executeUpdate(Order.insertQuery, values: [
                        code, status, secret, email as Any, checkin_attention as Any,
                        require_approval as Any, json as Any])
                } catch {
                    print(error)
                }
            }
        }
    }

    func store(_ records: [OrderPosition], in queue: FMDatabaseQueue) {
        for record in records {
            store(record.checkins, for: record, in: queue)

            queue.inDatabase { database in
                let identifier = record.identifier as Int
                let order = record.order
                let positionid = record.positionid
                let item = record.item
                let variation = record.variation
                let price = record.price as String
                let attendee_name = record.attendeeName
                let attendee_email = record.attendeeEmail
                let secret = record.secret
                let pseudonymization_id = record.pseudonymizationId

                do {
                    try database.executeUpdate(OrderPosition.insertQuery, values: [
                        identifier, order, positionid, item, variation as Any, price,
                        attendee_name as Any, attendee_email as Any, secret, pseudonymization_id])
                } catch {
                    print(error)
                }
            }
        }
    }

    func store(_ records: [CheckIn], for orderPosition: OrderPosition, in queue: FMDatabaseQueue) {
        queue.inDatabase { database in
            for record in records {
                let list = record.listID as Int
                let order_position = orderPosition.identifier as Int
                let date = record.date.toJSONString()

                do {
                    try database.executeUpdate(CheckIn.insertQuery, values: [
                        list, order_position, date as Any])
                } catch {
                    print(error)
                }
            }
        }
    }

    func store(_ records: [QueuedRedemptionRequest], in queue: FMDatabaseQueue) {
        queue.inDatabase { database in
            for record in records {
                let event_id = record.eventSlug
                let check_in_list_id = record.checkInListIdentifier as Int
                let secret = record.secret
                let questions_supported = record.redemptionRequest.questionsSupported.toInt()
                let datetime = record.redemptionRequest.date?.toJSONString()
                let force = record.redemptionRequest.force.toInt()
                let ignore_unpaid = record.redemptionRequest.ignoreUnpaid.toInt()
                let nonce = record.redemptionRequest.nonce

                do {
                    try database.executeUpdate(QueuedRedemptionRequest.insertQuery, values: [
                        event_id, check_in_list_id, secret, questions_supported, datetime as Any, force,
                        ignore_unpaid, nonce])
                } catch {
                    print(error)
                }
            }
        }
    }
}

// MARK: Type conversions to and from Sqlite
extension Bool {
    func toInt() -> Int {
        return self ? 1 : 0
    }
}

extension Int {
    func toBool() -> Bool {
        return self > 0
    }
}

extension Model {
    func toJSONString() -> String? {
        if let data = try? JSONEncoder.iso8601withFractionsEncoder.encode(self) {
            return String(data: data, encoding: .utf8)
        }

        return nil
    }
}

extension Date {
    func toJSONString() -> String? {
        if let data = try? JSONEncoder.iso8601withFractionsEncoder.encode(self) {
            return String(data: data, encoding: .utf8)
        }

        return nil
    }

    static func from(jsonString: String?) -> Date? {
        guard let jsonString = jsonString else { return nil }

        if let data = jsonString.data(using: .utf8),
            let date = try? JSONDecoder.iso8601withFractionsDecoder.decode(Date.self, from: data) {
            return date
        }

        return nil
    }
}
