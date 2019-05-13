//
//  FMDBDataStore.swift
//  PretixScan
//
//  Created by Daniel Jilg on 11.04.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

/// DataStore that uses FMDB to store data inside a MySQL file
///
/// - Note: See `DataStore` for function level documentation.
public class FMDBDataStore: DataStore {
    public func invalidateLastSynced(in event: Event) {
        // TODO
    }

    public func setLastSyncTime<T>(_ dateString: String, of model: T.Type, in event: Event) where T: Model {
        // TODO
    }

    public func lastSyncTime<T>(of model: T.Type, in event: Event) -> String? where T: Model {
        // TODO
        return nil
    }

    public func store<T>(_ resources: [T], for event: Event) where T: Model {
        // TODO
    }

    public func getEvents() -> [Event] {
        // TODO
        return []
    }

    public func getCheckInLists(for event: Event) -> [CheckInList] {
        // TODO
        return []
    }

    public func searchOrderPositions(_ query: String, in event: Event) -> [OrderPosition] {
        // TODO
        return []
    }

    public func redeem(secret: String, force: Bool, ignoreUnpaid: Bool, in event: Event, in checkInList: CheckInList)
        -> RedemptionResponse? {
        // TODO
        return nil
    }

    public func numberOfRedemptionRequestsInQueue(in event: Event) -> Int {
        // TODO
        return 0
    }

    public func getRedemptionRequest(in event: Event) -> QueuedRedemptionRequest? {
        // TODO
        return nil
    }

    public func delete(_ queuedRedemptionRequest: QueuedRedemptionRequest, in event: Event) {
        // TODO
    }

}
