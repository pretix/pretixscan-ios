//
//  PXSecurityProfile+defaults.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 07/02/2022.
//  Copyright © 2022 rami.io. All rights reserved.
//

import Foundation

extension PXSecurityProfile {
    
    func defaultValue(for key: DefaultsConfigStore.Keys) -> Bool {
        switch self {
        case .full:
            switch key {
            case .shouldDownloadOrders:
                return true
            case .enableSearch:
                return true
            default:
                return false
            }
        case .pretixscan:
            switch key {
            case .shouldDownloadOrders:
                return true
            case .enableSearch:
                return true
            default:
                return false
            }
        case .noOrders:
            switch key {
            case .shouldDownloadOrders:
                return false
            case .enableSearch:
                return true
            default:
                return false
            }
        case .kiosk:
            switch key {
            case .shouldDownloadOrders:
                return false
            case .enableSearch:
                return false
            default:
                return false
            }
        }
    }
}
