//
//  ConfiguredNavigationController.swift
//  PretixScan
//
//  Created by Daniel Jilg on 18.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

protocol Configurable {
    var configStore: ConfigStore? { get set }
}

protocol AppCoordinator {
    func getConfigStore() -> ConfigStore
    func redeem(_ orderPosition: OrderPosition, force: Bool, ignoreUnpaid: Bool)
}

/// Subclass of UINavigationController that saves a ConfigStore
///
/// If your UIViewController is marked as implementing the Configurable protocol
/// it will automatially get assigned a ConfigStore when it gets pushed.
class ConfiguredNavigationController: UINavigationController {
    var configStore: ConfigStore? { didSet { configureTopViewController() } }

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        configureTopViewController()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureTopViewController()
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        configureTopViewController()
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        configureTopViewController()
    }

    private func configureTopViewController() {
        print("Configuring", topViewController as Any)

        guard let viewController = topViewController else { return }

        if var configurableViewController = viewController as? Configurable, configurableViewController.configStore == nil {
            configurableViewController.configStore = self.configStore
        }

    }
}
