//
//  OnlineTicketValidator.swift
//  PretixScan
//
//  Created by Daniel Jilg on 19.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

/// Uses the APIClient directly to check the validity of tickets.
///
/// Does not add anything to DataStore's queue, but instead returns errors if no network available
public class OnlineTicketValidator: TicketValidator {
    private let configStore: ConfigStore

    public init(configStore: ConfigStore) {
        self.configStore = configStore
    }

    public func search(query: String, completionHandler: @escaping ([OrderPosition]?, Error?) -> Void) {
        configStore.apiClient?.getSearchResults(query: query, completionHandler: completionHandler)
    }
}
