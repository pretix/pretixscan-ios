//
//  ConfiguredNavigationController.swift
//  PretixScan
//
//  Created by Daniel Jilg on 18.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

/// Subclass of UINavigationController that saves a ConfigStore
class ConfiguredNavigationController: UINavigationController {
    var configStore: ConfigStore?
}
