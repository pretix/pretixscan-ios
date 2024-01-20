//
//  TicketJsonLogicChecker+configStore.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 12/09/2023.
//  Copyright © 2023 rami.io. All rights reserved.
//

import Foundation
import UIKit

extension TicketJsonLogicChecker {
    /// Returns a reference to the current config store.
    func getConfigStore() -> ConfigStore {
        return DefaultsConfigStore(defaults: UserDefaults.standard)
    }
}
