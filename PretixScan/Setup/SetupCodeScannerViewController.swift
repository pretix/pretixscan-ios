//
//  SetupCodeScannerViewController.swift
//  PretixScan
//
//  Created by Daniel Jilg on 02.04.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class SetupCodeScannerViewController: ScannerViewController {
    override func viewDidLoad() {
        shouldScan = true
        super.viewDidLoad()
    }

    override func found(code: String) {
        print(code)
    }
}
