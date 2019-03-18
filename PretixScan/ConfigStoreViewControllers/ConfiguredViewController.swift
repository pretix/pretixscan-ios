//
//  ConfiguredViewController.swift
//  PretixScan
//
//  Created by Daniel Jilg on 18.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

/// Subclass of UIViewController that automatically retrieves a
/// ConfigStore from a hopefully-present ConfiguredNavigationController
class ConfiguredViewController: UIViewController {
    var configStore: ConfigStore? {
        if let configuredNavigationController = self.navigationController as? ConfiguredNavigationController {
            return configuredNavigationController.configStore
        }
        return nil
    }
}
