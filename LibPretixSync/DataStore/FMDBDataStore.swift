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

    private var lastSynced = [String: String]()
    public func storeLastSynced(_ data: [String: String]) {
        lastSynced = data
    }

    public func retrieveLastSynced() -> [String: String] {
        return lastSynced
    }

    public func store<T: Model>(_ resources: [T], for event: Event) {

    }
}
