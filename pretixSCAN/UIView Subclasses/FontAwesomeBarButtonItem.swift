//
//  FontAwesomeBarbuttonItem.swift
//  PretixScan
//
//  Created by Daniel Jilg on 04.04.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class FontAwesomeBarButtonItem: UIBarButtonItem {
    override init() {
        super.init()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        let fontAwesome = "FontAwesome5Free-Solid"
        let controlStates: [UIControl.State] = [.normal, .highlighted, .disabled, .focused]
        for state in controlStates {
            setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: fontAwesome, size: 17)!], for: state)
        }
    }
}
