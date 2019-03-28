//
//  TicketScannerViewController.swift
//  PretixScan
//
//  Created by Daniel Jilg on 27.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class TicketScannerViewController: ScannerViewController {
    var appCoordinator: AppCoordinator?

    override func found(code: String) {
        appCoordinator?.redeem(secret: code, force: false, ignoreUnpaid: false)
    }
}
