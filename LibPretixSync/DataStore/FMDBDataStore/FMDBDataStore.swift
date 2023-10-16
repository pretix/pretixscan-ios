//
//  FMDBDataStore.swift
//  PretixScan
//
//  Created by Daniel Jilg on 11.04.19.
//  Copyright © 2019 rami.io. All rights reserved.
//
// swiftlint:disable force_try
// swiftlint:disable file_length
// swiftlint:disable function_parameter_count

import Foundation
import FMDB

/// DataStore that uses FMDB to store data inside a MySQL file
///
/// - Note: See `DataStore` for function level documentation.
public class FMDBDataStore: DataStore {
    private lazy var uploadDataBaseQueue: FMDatabaseQueue = { return createUploadDataBaseQueue() }()
    
    private var currentDataBaseQueue: FMDatabaseQueue?
    private var currentDataBaseQueueEvent: Event?
    
    // MARK: Metadata
    
    public func destroyDataStoreForUploads() {
        uploadDataBaseQueue.close()
        let fileURL = try! getUploadsFileUrl()!
        
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch let error {
            EventLogger.log(
                event: "Could not delete Database file: \(error.localizedDescription)",
                category: .database, level: .warning, type: .error)
        }
        
        // Always recreate
        uploadDataBaseQueue = createUploadDataBaseQueue()
    }
    
    /// Delete all data regarding an event, except queued redemption requests.
    public func destroyDataStore(for event: Event, recreate: Bool) {
        deleteDatabase(for: event)
        
        if recreate {
            // Recreate the database
            _ = databaseQueue(with: event, recreate: true)
        }
        
        // Send out notification
        NotificationCenter.default.post(name: SyncManager.syncStatusResetNotification, object: nil)
    }
    
    /// Remove all Sync Times and pretend nothing was ever synced
    public func invalidateLastSynced(in event: Event) {
        // Drop Sync Times Database
        databaseQueue(with: event).inDatabase { database in
            do {
                try database.executeUpdate(SyncTimeStamp.destructionQuery, values: nil)
                try database.executeUpdate(SyncTimeStamp.creationQuery, values: nil)
            } catch {
                EventLogger.log(event: error.localizedDescription, category: .database, level: .fatal, type: .error)
            }
        }
        
        // Send out notification
        NotificationCenter.default.post(name: SyncManager.syncStatusResetNotification, object: nil)
    }
    
    /// Store timestamps of the last syncs
    public func setLastSyncModifiedTime<T>(_ dateString: String, of model: T.Type, in event: Event) where T: Model {
        databaseQueue(with: event).inDatabase { database in
            do {
                try database.executeUpdate(SyncTimeStamp.insertQuery, values: [model.stringName, dateString])
            } catch {
                EventLogger.log(event: "\(error.localizedDescription)", category: .database, level: .fatal, type: .error)
            }
        }
    }
    
    /// Retrieve timestamps of the last syncs
    public func lastSyncTime<T>(of model: T.Type, in event: Event) -> String? where T: Model {
        var lastSyncedAt: String?
        databaseQueue(with: event).inDatabase { database in
            if let result = try? database.executeQuery(SyncTimeStamp.getSingleModelQuery, values: [model.stringName]) {
                while result.next() {
                    lastSyncedAt = result.string(forColumn: "last_synced_at")
                }
            }
        }
        
        return lastSyncedAt?.count == 0 ? nil : lastSyncedAt
    }
    
    public func setLastSyncCreatedTime<T: Model>(_ dateString: String, of model: T.Type, in event: Event) {
        databaseQueue(with: event).inDatabase { database in
            do {
                try database.executeUpdate(SyncTimeStamp.insertQuery, values: [model.stringName + "partial", dateString])
            } catch {
                EventLogger.log(event: "\(error.localizedDescription)", category: .database, level: .fatal, type: .error)
            }
        }
    }
    
    public func lastSyncCreationTime<T: Model>(of model: T.Type, in event: Event) -> String? {
        var lastSyncedAt: String?
        databaseQueue(with: event).inDatabase { database in
            if let result = try? database.executeQuery(SyncTimeStamp.getSingleModelQuery, values: [model.stringName + "partial"]) {
                while result.next() {
                    lastSyncedAt = result.string(forColumn: "last_synced_at")
                }
            }
        }
        
        return lastSyncedAt?.count == 0 ? nil : lastSyncedAt
    }
    
    // MARK: - Storing
    
    public func store<T>(_ resource: T, for event: Event) where T: Model {
        self.store([resource], for: event)
    }
    
    /// Store a list of `Model`s related to an `Event`
    public func store<T>(_ resources: [T], for event: Event) where T: Model {
        let queue = databaseQueue(with: event)
        
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
            QueuedRedemptionRequest.store(queuedRedemptionRequests, in: uploadDataBaseQueue)
            return
        }
        
        if let questions = resources as? [Question] {
            Question.store(questions, in: queue)
            return
        }
        
        if let failedCheckIns = resources as? [FailedCheckIn] {
            FailedCheckIn.store(failedCheckIns, in: uploadDataBaseQueue)
            return
        }
        
        if let revokedSecrets = resources as? [RevokedSecret] {
            RevokedSecret.store(revokedSecrets, eventSlug: event.slug, in: queue)
            return
        }
        
        if let blockedSecrets = resources as? [BlockedSecret] {
            BlockedSecret.store(blockedSecrets, eventSlug: event.slug, in: queue)
            return
        }
        
        if let validKeys = resources as? [EventValidKey] {
            EventValidKey.store(validKeys, eventSlug: event.slug, in: queue)
            return
        }
        
        EventLogger.log(event: "Don't know how to store \(T.humanReadableName)", category: .offlineDownload, level: .warning, type: .fault)
    }
}

// MARK: - Retrieving
extension FMDBDataStore {
    // Return all `OrderPosition`s matching the given query
    public func searchOrderPositions(_ query: String, in event: Event, checkInList: CheckInList,
                                     completionHandler: @escaping ([OrderPosition]?, Error?) -> Void) {
        let queue = databaseQueue(with: event)
        
        DispatchQueue.global().async {
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
                let populatedOrderPosition = orderPosition
                    .adding(checkIns: self.getCheckIns(for: orderPosition, in: event))
                    .adding(item: self.getItem(by: orderPosition.itemIdentifier, in: event))
                    .adding(order: self.getOrder(by: orderPosition.orderCode, in: event))
                foundOrderPositions.append(populatedOrderPosition)
            }
            
            // Filter positions without the correct product
            let filteredOrderPositions = foundOrderPositions.filter { orderPosition in
                if !checkInList.allProducts {
                    return checkInList.limitProducts?.contains(orderPosition.itemIdentifier) == true
                }
                
                return true
            }
            
            // Filter positions without the correct sub event
                .filter { orderPosition in
                    return checkInList.subEvent == nil || orderPosition.subEvent == checkInList.subEvent
                }
            
            completionHandler(filteredOrderPositions, nil)
        }
    }
    
    public func getCheckIns(for orderPosition: OrderPosition, in event: Event) -> [CheckIn] {
        var checkIns = [CheckIn]()
        databaseQueue(with: event).inDatabase { database in
            if let result = try? database.executeQuery(CheckIn.retrieveByOrderPositionQuery, values: [orderPosition.identifier]) {
                while result.next() {
                    if let nextCheckin = CheckIn.from(result: result, in: database) { checkIns.append(nextCheckin) }
                }
            }
        }
        
        return checkIns
    }
    
    public func getSubEvents(for event: Event) -> Result<[SubEvent], Error> {
        var results = [SubEvent]()
        databaseQueue(with: event).inDatabase { database in
            if let result = try? database.executeQuery(SubEvent.searchByEventQuery, values: [event.slug]) {
                while result.next() {
                    if let subEvent = SubEvent.from(result: result, in: database) { results.append(subEvent) }
                }
            }
        }
        return .success(results)
    }
    
    public func getSubEvent(id: Identifier, for event: Event) -> Result<SubEvent?, Error> {
        var subEvent: SubEvent? = nil
        databaseQueue(with: event).inDatabase { database in
            if let result = try? database.executeQuery(SubEvent.searchById, values: [id]) {
                while result.next() {
                    if let item = SubEvent.from(result: result, in: database) { subEvent = item }
                }
            }
        }
        return .success(subEvent)
    }
    
    public func getCheckIns(for orderPosition: OrderPosition, in checkInList: CheckInList?, in event: Event) -> [CheckIn] {
        guard let checkInList = checkInList else {
            return []
        }
        
        let checkIns = getCheckIns(for: orderPosition, in: event).filter {
            $0.listID == checkInList.identifier
        }
        
        return checkIns
    }
    
    public func getOrder(by code: String, in event: Event) -> Order? {
        let queue = databaseQueue(with: event)
        return Order.getOrder(by: code, in: queue)
    }
    
    public func getCheckInListStatus(_ checkInList: CheckInList, in event: Event) -> Result<CheckInListStatus, Error> {
        let queue = databaseQueue(with: event)
        
        // Get CheckIn Count
        let checkInCount = CheckIn.countCheckIns(for: checkInList, in: queue)
        
        // Get Positions Count
        let positionsCount = OrderPosition.countOrderPositions(for: checkInList, in: queue)
        
        // Get Items for CheckInList
        let allItems = Item.getAllItems(in: queue)
        var itemsForCheckInList = allItems
        if let limitProducts = checkInList.limitProducts, checkInList.allProducts == false {
            itemsForCheckInList = allItems.filter { return limitProducts.contains($0.identifier) }
        }
        
        // Loop through items
        var checkInListStatusItems = [CheckInListStatus.Item]()
        for item in itemsForCheckInList {
            let itemCheckInCount = CheckIn.countCheckIns(of: item.identifier, for: checkInList, in: queue)
            let itemPositionsCount = OrderPosition.countOrderPositions(of: item.identifier, for: checkInList, in: queue)
            
            var variations = [CheckInListStatus.Item.Variation]()
            for variation in item.variations {
                let variationCheckInCount = CheckIn.countCheckIns(of: item.identifier, variation: variation.identifier,
                                                                  for: checkInList, in: queue)
                let variationPositionsCount = OrderPosition.countOrderPositions(of: item.identifier, variation: variation.identifier,
                                                                                for: checkInList, in: queue)
                
                
                let variationName = variation.name.representation(in: Locale.current) ?? ""
                let variationItem = CheckInListStatus.Item.Variation(value: variationName,
                                                                     identifier: variation.identifier, checkinCount: variationCheckInCount,
                                                                     positionCount: variationPositionsCount)
                variations.append(variationItem)
            }
            
            let itemName = item.name.representation(in: Locale.current) ?? ""
            let checkInListStatusItem = CheckInListStatus.Item(name: itemName,
                                                               identifier: item.identifier, checkinCount: itemCheckInCount,
                                                               admission: false, positionCount: itemPositionsCount,
                                                               variations: variations)
            
            checkInListStatusItems.append(checkInListStatusItem)
        }
        
        /// The insideCount is not supported in offline mode, https://code.rami.io/pretix/pretixscan-ios/-/issues/69
        let status = CheckInListStatus(checkinCount: checkInCount, positionCount: positionsCount, insideCount: -1, items: checkInListStatusItems)
        return .success(status)
    }
    
}

// MARK: - Checking In
extension FMDBDataStore {
    /// Check in an attendee, identified by their secret, into the currently configured CheckInList
    ///
    /// Will return `nil` if no orderposition with the specified secret is found
    public func redeem(secret: String, force: Bool, ignoreUnpaid: Bool, answers: [Answer]?, in event: Event,
                       as type: String,
                       in checkInList: CheckInList)
    -> RedemptionResponse? {
        let queue = databaseQueue(with: event)
        
        // Retrieve OrderPosition and its CheckIns
        let tickets = OrderPosition.getAll(secret: secret, in: queue)
        if tickets.isEmpty {
            return nil
        }
        
        if tickets.count > 1 {
            return RedemptionResponse.ambiguous
        }
        
        var tempOrderPosition = tickets[0]
        
        let parentTicket = tempOrderPosition
            .adding(item: getItem(by: tempOrderPosition.itemIdentifier, in: event))
        
        if checkInList.addonMatch {
            var candidates = [tempOrderPosition]
            candidates
                .append(contentsOf:
                            (getOrder(by: tempOrderPosition.orderCode, in: event)?.positions ?? []).filter({$0.addonTo == tempOrderPosition.identifier})
                )
            
            logger.debug("Addon matching with \(candidates.count) candidate tickets.")
            
            if !checkInList.allProducts, let itemIds = checkInList.limitProducts {
                candidates = candidates.filter({candidate in itemIds.contains(candidate.itemIdentifier)
                })
            }
            
            logger.debug("Filtered to \(candidates.count) candidate tickets.")
            
            if candidates.isEmpty {
                return RedemptionResponse.product
            }
            
            if candidates.count > 1 {
                return RedemptionResponse.ambiguous
            }
            
            tempOrderPosition = candidates[0]
        }
        
        let checkIns = getCheckIns(for: tempOrderPosition, in: checkInList, in: event)
        
        var orderPosition = tempOrderPosition
            .adding(checkIns: checkIns)
            .adding(item: getItem(by: tempOrderPosition.itemIdentifier, in: event))
            .adding(order: getOrder(by: tempOrderPosition.orderCode, in: event))
            .adding(parentTicket: parentTicket)
            .adding(answers: answers)
        
        if event.hasSubEvents, let subEventId = tempOrderPosition.subEvent {
            let subEvent = try? self.getSubEvent(id: subEventId, for: event).get()
            orderPosition = orderPosition.adding(subEvent: subEvent)
        }
        
        
        let questions = try! getQuestions(for: orderPosition.item!, in: event).get()
        
        guard let redemptionResponse = orderPosition.createRedemptionResponse(
            force: force, ignoreUnpaid: ignoreUnpaid,
            in: event, in: checkInList, as: type, with: questions, dataStore: self) else { return nil }
        
        guard redemptionResponse.status == .redeemed else {
            return RedemptionResponse.appendMetadataForStatusVisualization(redemptionResponse.with(reason: .notRedeemed), orderPosition: orderPosition)
        }
        
        // Store a queued redemption request
        let checkInDate = Date()
        let redemptionRequest = RedemptionRequest(
            questionsSupported: true,
            date: checkInDate, force: true, ignoreUnpaid: ignoreUnpaid,
            nonce: NonceGenerator.nonce(), answers: answers, type: type)
        let queuedRedemptionRequest = QueuedRedemptionRequest(
            redemptionRequest: redemptionRequest,
            eventSlug: event.slug,
            checkInListIdentifier: checkInList.identifier,
            secret: secret)
        
        QueuedRedemptionRequest.store([queuedRedemptionRequest], in: uploadDataBaseQueue)
        
        // Save a check in to check the attendee in
        // This checkin will later be overwritten (or duplicated) by one synced down from the server
        let checkIn = CheckIn(listID: checkInList.identifier, date: checkInDate, type: type)
        CheckIn.store([checkIn], for: orderPosition, in: queue)
        
        // return the redeemed request
        return redemptionResponse.with(reason: .redeemedRequest)
    }
}

// MARK: - Queueing
extension FMDBDataStore {
    /// Return a `QueuedRedemptionRequest` instance that has not yet been uploaded to the server
    ///
    /// This implementation will deliberately return a random instance each time, in order to not block the upload queue with
    /// a malformed request forever.
    public func getRedemptionRequest() -> QueuedRedemptionRequest? {
        var redemptionRequest: QueuedRedemptionRequest?
        uploadDataBaseQueue.inDatabase { database in
            if let result = try? database.executeQuery(QueuedRedemptionRequest.retrieveOneRequestQuery, values: []) {
                while result.next() {
                    redemptionRequest = QueuedRedemptionRequest.from(result: result, in: database)
                }
            }
        }
        
        return redemptionRequest
    }
    
    /// Remove a `QeuedRedemptionRequest` instance from the database
    public func delete(_ queuedRedemptionRequest: QueuedRedemptionRequest) {
        uploadDataBaseQueue.inDatabase { database in
            do {
                try database.executeUpdate(QueuedRedemptionRequest.deleteOneRequestQuery,
                                           values: [queuedRedemptionRequest.redemptionRequest.nonce])
            } catch {
                EventLogger.log(event: "\(error.localizedDescription)", category: .database, level: .fatal, type: .error)
            }
        }
    }
    
    public func getFailedCheckIn() -> (Int?, FailedCheckIn?) {
        var rowId: Int? = nil
        var item: FailedCheckIn? = nil
        uploadDataBaseQueue.inDatabase { database in
            if let result = try? database.executeQuery(FailedCheckIn.retrieveOneQuery, values: []) {
                while result.next() {
                    rowId = Int(result.int(forColumn: "rowid"))
                    item = FailedCheckIn.from(result: result, in: database)
                }
            }
        }
        
        return (rowId, item)
    }
    
    public func delete(failedCheckInRowId: Int) {
        uploadDataBaseQueue.inDatabase { database in
            do {
                try database.executeUpdate(FailedCheckIn.deleteOneQuery,
                                           values: [failedCheckInRowId])
            } catch {
                EventLogger.log(event: "\(error.localizedDescription)", category: .database, level: .fatal, type: .error)
            }
        }
    }
    
}

// MARK: - Database File Management
private extension FMDBDataStore {
    static let UploadsDatabaseFileName: String = "uploads.sqlite"
    
    private func getUploadsFileUrl() throws -> URL? {
        return try FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(Self.UploadsDatabaseFileName)
    }
    
    private func createUploadDataBaseQueue() -> FMDatabaseQueue {
        let fileURL = try! getUploadsFileUrl()!
        print("Opening Database \(fileURL.path)")
        let queue = FMDatabaseQueue(url: fileURL)
        
        migrateUploads(queue: queue!)
        
        return queue!
    }
    
    /// Delete the database file
    func deleteDatabase(for event: Event) {
        databaseQueue(with: event).close()
        let fileURL = try! FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("\(event.slug).sqlite")
        
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch let error {
            EventLogger.log(
                event: "Could not delete Database file: \(error.localizedDescription)",
                category: .database, level: .warning, type: .error)
        }
        
    }
    
    func databaseQueue(with event: Event, recreate: Bool = false) -> FMDatabaseQueue {
        // If we're dealing with the same database as last time, keep it open
        // except in case the caller specifically asked us to recreate the DB.
        if currentDataBaseQueueEvent == event, let queue = currentDataBaseQueue, !recreate {
            return queue
        }
        
        // Otherwise, close it...
        currentDataBaseQueue?.close()
        
        // ... and open a new queue
        let fileURL = try! FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("\(event.slug).sqlite")
        print("Opening Database \(fileURL.path)")
        guard let queue = FMDatabaseQueue(url: fileURL) else {
            EventLogger.log(
                event: "Could not create queue for database \(fileURL)",
                category: .database, level: .warning, type: .error)
            fatalError()
        }
        
        migrate(queue: queue)
        
        // Cache the queue for later usage
        currentDataBaseQueue = queue
        currentDataBaseQueueEvent = event
        
        return queue
    }
}

// MARK: - DatalessDataStore
extension FMDBDataStore {
    
    public func getQuestions(for item: Item, in event: Event) -> Result<[Question], Error> {
        var questions = [Question]()
        
        databaseQueue(with: event).inDatabase { database in
            if let result = try? database.executeQuery(Question.checkInQuestionsWithItemQuery, values: []) {
                while result.next() {
                    if let question = Question.from(result: result, in: database), question.items.contains(item.identifier) {
                        questions.append(question)
                    }
                }
            }
        }
        
        return .success(questions)
    }
    
    public func getItem(by identifier: Identifier, in event: Event) -> Item? {
        let queue = databaseQueue(with: event)
        return Item.getItem(by: identifier, in: queue)
    }
    
    public func getValidKeys(for event: Event) -> Result<[EventValidKey], Error> {
        var items = [EventValidKey]()
        
        databaseQueue(with: event).inDatabase { database in
            if let result = try? database.executeQuery(EventValidKey.searchByEventQuery, values: [event.slug]) {
                while result.next() {
                    if let item = EventValidKey.from(result: result, in: database) {
                        items.append(item)
                    }
                }
            }
        }
        
        return .success(items)
    }
    
    public func getRevokedKeys(for event: Event) -> Result<[RevokedSecret], Error> {
        var items = [RevokedSecret]()
        
        databaseQueue(with: event).inDatabase { database in
            if let result = try? database.executeQuery(RevokedSecret.searchByEventQuery, values: [event.slug]) {
                while result.next() {
                    if let item = RevokedSecret.from(result: result, in: database) {
                        items.append(item)
                    }
                }
            }
        }
        
        return .success(items)
    }
    
    public func getBlockedKeys(for event: Event) -> Result<[BlockedSecret], Error> {
        var items = [BlockedSecret]()
        
        databaseQueue(with: event).inDatabase { database in
            if let result = try? database.executeQuery(BlockedSecret.searchByEventQuery, values: [event.slug]) {
                while result.next() {
                    if let item = BlockedSecret.from(result: result, in: database) {
                        items.append(item)
                    }
                }
            }
        }
        
        return .success(items)
    }
    
    public func getQueuedCheckIns(_ secret: String, eventSlug: String, listId: Identifier) -> Result<[QueuedRedemptionRequest], Error> {
        var items = [QueuedRedemptionRequest]()
        
        uploadDataBaseQueue.inDatabase { database in
            if let result = try? database.executeQuery(QueuedRedemptionRequest.retrieveForTicketInEvent, values: [eventSlug, secret]) {
                while result.next() {
                    if let item = QueuedRedemptionRequest.from(result: result, in: database) {
                        items.append(item)
                    }
                }
            }
        }
        
        return .success(items.filter({$0.checkInListIdentifier == listId}))
    }
    
    public func getOrderCheckIns(_ secret: String, type: String, _ event: Event, listId: Identifier) -> [OrderPositionCheckin] {
        if let order = Order.getOrder(secret: secret, in: databaseQueue(with: event)) {
            return order.getPreviousCheckIns(secret: secret, listId: listId).filter({$0.checkInType == type})
        }
        
        return []
    }
}
