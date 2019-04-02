//
//  AppCoordinator.swift
//  PretixScan
//
//  Created by Daniel Jilg on 02.04.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

/// Coordinates and routes actions between parts of the system
///
/// One Class, ValidateTicketViewController, is implementing the appcoordinator protocol.
protocol AppCoordinator {
    func getConfigStore() -> ConfigStore
    func redeem(secret: String, force: Bool, ignoreUnpaid: Bool)
    func performHapticNotification(ofType type: UINotificationFeedbackGenerator.FeedbackType)
}

/// Classes that are marked as appCoordinatorReceiver will get their appcoordinator
/// property set. Use AppCoordinator for anything that needs to be a singleton
protocol AppCoordinatorReceiver {
    var appCoordinator: AppCoordinator? { get set }
}
