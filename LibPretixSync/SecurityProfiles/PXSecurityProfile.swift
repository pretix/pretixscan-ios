//
//  PXSecurityProfile.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 31/01/2022.
//  Copyright © 2022 rami.io. All rights reserved.
//

import Foundation

/// API Security profile level. Check https://github.com/pretix/pretix/blob/master/src/pretix/api/auth/devicesecurity.py#L42 for a full description
public enum PXSecurityProfile: String, CaseIterable {
    /// Everything is allowed
    case full = "full"
    /// Everything you need to allow all functionality of the scan app is allowed, everything else is blocked
    case pretixscan = "pretixscan"
    /// Used if there are strict privacy regulations or if the data set is really large
    case noOrders = "pretixscan_online_noorders"
    
    /// Used if the device is used as a kiosk device, i.e. self-service check-in for users
    case kiosk = "pretixscan_online_kiosk"
    
    init(rawValue: String?) {
        guard let rawValue = rawValue else {
            self = .full
            return
        }
        guard let knownValue = PXSecurityProfile(rawValue: rawValue) else {
            self = .full
            return
        }
        self = knownValue
    }
}
