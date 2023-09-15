//
//  UIViewController+navBarControls.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 11/09/2023.
//  Copyright © 2023 rami.io. All rights reserved.
//

import UIKit

extension UIViewController {
    /// Removes the left bar button
    func clearLeadingBavBarAction() {
        navigationItem.setLeftBarButton(nil, animated: false)
    }
    
    /// Hides the back button if any was set by the parent view controller. Call this in the `viewDidLoad` phase of the child controller.
    func hideNavBarBackButton() {
        navigationItem.setHidesBackButton(true, animated:false)
    }
    
    /// Sets the trailing navigation bar action to a button for the specific action
    func setTrailingNavBarAction(title: String?, selector: Selector?, target: Any) {
        let textButton = UIBarButtonItem(title: title, style: .plain, target: target, action: selector)
        navigationItem.setRightBarButton(textButton, animated: false)
    }
    
    /// Sets the leading navigation bar action to a button for the specific action
    func setLeadingNavBarAction(title: String?, selector: Selector?, target: Any) {
        let textButton = UIBarButtonItem(title: title, style: .plain, target: target, action: selector)
        navigationItem.setLeftBarButton(textButton, animated: false)
    }
}

