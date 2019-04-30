//
//  InMemoryDataStore.swift
//  PretixScan
//
//  Created by Daniel Jilg on 15.04.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

/// DataStore that stores data in memory for debugging and testing.
///
/// - Note: See `DataStore` for function level documentation.
public class InMemoryDataStore: DataStore {
    // MARK: - Last Synced
    public func invalidateLastSynced(in event: Event) {
        dataStore(for: event).lastSynced = [String: String]()
    }

    public func setLastSyncTime<T: Model>(_ dateString: String, of model: T.Type, in event: Event) {
        dataStore(for: event).lastSynced[model.urlPathPart] = dateString
    }

    public func lastSyncTime<T: Model>(of model: T.Type, in event: Event) -> String? {
        return dataStore(for: event).lastSynced[model.urlPathPart]
    }

    // MARK: - Storing
    public func store<T: Model>(_ resources: [T], for event: Event) {
        if let events = resources as? [Event] {
            for event in events {
                self.events.insert(event)
            }
        } else if let checkInLists = resources as? [CheckInList] {
            for checkInList in checkInLists {
                 dataStore(for: event).checkInLists.insert(checkInList)
            }
        } else if let orders = resources as? [Order] {
            for order in orders {
                dataStore(for: event).orders.insert(order)
            }
        } else if let itemCategories = resources as? [ItemCategory] {
            for itemCategory in itemCategories {
                dataStore(for: event).itemCategories.insert(itemCategory)
            }
        } else if let items = resources as? [Item] {
            for item in items {
                dataStore(for: event).items.insert(item)
            }
        }
    }

    // MARK: - Retrieving
    public func getEvents() -> [Event] {
        return Array(events)
    }

    public func getCheckInLists(for event: Event) -> [CheckInList] {
        return Array(dataStore(for: event).checkInLists)
    }

    public func searchOrderPositions(_ query: String, in event: Event) -> [OrderPosition] {
        var searchResult = [OrderPosition]()
        for order in dataStore(for: event).orders {
            if let email = order.email, email.contains(query), let positions = order.positions {
                searchResult += positions
            } else {
                searchResult += (order.positions ?? [OrderPosition]()).filter({ orderPosition -> Bool in
                    return (
                        (orderPosition.attendeeName ?? "").contains(query) ||
                        (orderPosition.attendeeEmail ?? "").contains(query) ||
                        orderPosition.order.contains(query)
                    )
                })
            }
        }
        return searchResult
    }

    public func redeem(secret: String, force: Bool, ignoreUnpaid: Bool) -> RedemptionResponse {
        return RedemptionResponse(status: .error, errorReason: .alreadyRedeemed, position: nil)
    }

    // MARK: - Internal
    private var events = Set<Event>()
    private var inMemoryEventDataStores = [String: InMemoryEventDataStore]()

    private func dataStore(for event: Event) -> InMemoryEventDataStore {
        guard let dataStore = inMemoryEventDataStores[event.slug] else {
            let newDataStore = InMemoryEventDataStore()
            inMemoryEventDataStores[event.slug] = newDataStore
            return newDataStore
        }
        return dataStore
    }
}

private class InMemoryEventDataStore {
    fileprivate var lastSynced = [String: String]()
    fileprivate var checkInLists = Set<CheckInList>()
    fileprivate var orders = Set<Order>()
    fileprivate var itemCategories = Set<ItemCategory>()
    fileprivate var items = Set<Item>()
}
