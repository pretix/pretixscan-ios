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
    /// Delete all data regarding an event, except queued redemption requests.
    func resetDataStore(for event: Event)

    /// Remove all Sync Times and pretend nothing was ever synced
    func invalidateLastSynced(in event: Event)

    /// Store timestamps of the last syncs
    func setLastSyncModifiedTime<T: Model>(_ dateString: String, of model: T.Type, in event: Event)

    /// Retrieve timestamps of the last syncs
    func lastSyncTime<T: Model>(of model: T.Type, in event: Event) -> String?

    /// Store timestamp for the last partially cleared full sync
    func setLastSyncCreatedTime<T: Model>(_ dateString: String, of model: T.Type, in event: Event)

    /// Retrieve timestamp for the last partially cleared full sync
    func lastSyncCreationTime<T: Model>(of model: T.Type, in event: Event) -> String?

    // MARK: - Storing
    /// Store a list of `Model`s related to an `Event`
    func store<T: Model>(_ resources: [T], for event: Event)

    // MARK: - Retrieving
    /// Return all `OrderPosition`s matching the given query
    func searchOrderPositions(_ query: String, in event: Event, checkInList: CheckInList,
                              completionHandler: @escaping ([OrderPosition]?, Error?) -> Void)

    /// Retrieve an `Item` instance with the specified identifier, is such an Item exists
    func getItem(by identifier: Identifier, in event: Event) -> Item?

    /// Retrieve an `Order` instance with the specified identifier, is such an Order exists
    func getOrder(by code: String, in event: Event) -> Order?

    /// Retrieve all CheckIns for the specified `OrderPosition`
    func getCheckIns(for orderPosition: OrderPosition, in event: Event) -> [CheckIn]

    /// Retrieve all CheckIns for the specified `OrderPosition` in the specified `CheckInList`
    func getCheckIns(for orderPosition: OrderPosition, in checkInList: CheckInList?, in event: Event) -> [CheckIn]

    /// Retrieve Statistics for the currently selected CheckInList
    func getCheckInListStatus(_ checkInList: CheckInList, in event: Event, subEvent: SubEvent?) -> Result<CheckInListStatus, Error>

    // MARK: - Redemption Requests
    /// Check in an attendee, identified by their secret, into the currently configured CheckInList
    ///
    /// Will return `nil` if no orderposition with the specified secret is found
    ///
    /// - See `RedemptionResponse` for the response returned in the completion handler.
    func redeem(secret: String, force: Bool, ignoreUnpaid: Bool, in event: Event, in checkInList: CheckInList) -> RedemptionResponse?

    /// Return the number of QueuedRedemptionReqeusts in the DataStore
    func numberOfRedemptionRequestsInQueue(in event: Event) -> Int

    /// Return a `QueuedRedemptionRequest` instance that has not yet been uploaded to the server
    func getRedemptionRequest(in event: Event) -> QueuedRedemptionRequest?

    /// Remove a `QeuedRedemptionRequest` instance from the database
    func delete(_ queuedRedemptionRequest: QueuedRedemptionRequest, in event: Event)
}
