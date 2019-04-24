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
    private var lastSynced = [String: String]()
    public func storeLastSynced(_ data: [String: String]) {
        lastSynced = data
    }

    public func retrieveLastSynced() -> [String: String] {
        return lastSynced
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
    fileprivate var checkInLists = Set<CheckInList>()
    fileprivate var orders = Set<Order>()
    fileprivate var itemCategories = Set<ItemCategory>()
    fileprivate var items = Set<Item>()
}
