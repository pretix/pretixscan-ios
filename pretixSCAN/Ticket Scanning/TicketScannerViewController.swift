//
//  TicketScannerViewController.swift
//  PretixScan
//
//  Created by Daniel Jilg on 27.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class TicketScannerViewController: ScannerViewController, AppCoordinatorReceiver {
    var appCoordinator: AppCoordinator?
    
    override func viewDidLoad() {
        // make sure the controller loads with the correct initial configuration
        preferFrontCamera = appCoordinator?.getConfigStore().preferFrontCamera ?? false
        super.viewDidLoad()
    }
    
    override func found(code: String) {
        appCoordinator?.redeem(secret: code, force: false, ignoreUnpaid: false)
    }
}
