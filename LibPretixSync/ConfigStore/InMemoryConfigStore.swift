//
//  DefaultsConfigStore.swift
//  PretixScan
//
//  Created by Daniel Jilg on 13.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

/// ConfigStore implementation that stores configuration in memory.
public class InMemoryConfigStore: ConfigStore {
    public var welcomeScreenIsConfirmed: Bool = false
    public var isConfigured: Bool = false
}
