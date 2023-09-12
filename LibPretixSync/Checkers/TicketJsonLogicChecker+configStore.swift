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
        guard let configStore = (UIApplication.shared.delegate as? AppDelegate)?.configStore else {
            fatalError("Could not get ConfigStore from AppDelegate")
        }
        return configStore
    }
}
