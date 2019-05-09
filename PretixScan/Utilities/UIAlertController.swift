//
//  UIAlertController.swift
//  PretixScan
//
//  Created by Daniel Jilg on 25.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {
    static func errorAlert(with error: Error) -> UIAlertController {
        let alert = UIAlertController(title: Localization.Errors.Error, message: getMessage(for: error), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Localization.Errors.Confirm, style: .default, handler: nil))
        return alert
    }

    static func getMessage(for error: Error) -> String {
        // TODO: return proper error messages

        return error.localizedDescription
    }
}
