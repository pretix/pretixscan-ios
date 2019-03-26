//
//  Utilities.swift
//  PretixScan
//
//  Created by Daniel Jilg on 14.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func presentErrorAlert(ifError error: Error?) {
        DispatchQueue.main.async {
            guard let error = error else { return }
            let alert = UIAlertController.errorAlert(with: error)
            self.present(alert, animated: true)
        }
    }
}
