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
                self.checkInLists.insert(checkInList)
            }
        } else if let orders = resources as? [Order] {
            for order in orders {
                self.orders.insert(order)
            }
        } else if let itemCategories = resources as? [ItemCategory] {
            for itemCategory in itemCategories {
                self.itemCategories.insert(itemCategory)
            }
        } else if let items = resources as? [Item] {
            for item in items {
                self.items.insert(item)
            }
        }
    }

    // MARK: - Retrieving
    public func getEvents() -> [Event] {
        return Array(events)
    }

    // MARK: - Internal
    private var events = Set<Event>()
    private var checkInLists = Set<CheckInList>()
    private var orders = Set<Order>()
    private var itemCategories = Set<ItemCategory>()
    private var items = Set<Item>()
}
