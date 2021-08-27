//
//  Color.swift
//  PretixScan
//
//  Created by Daniel Jilg on 26.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

struct Color {
    static let primary = UIColor(named: "primary")!
    static let primaryText = UIColor(named: "primaryText")!
    static let secondary = UIColor(named: "secondary")!
    static let grayBackground = UIColor(named: "grayBackground")!
    static let error = UIColor(named: "error")!
    static let warning = UIColor(named: "warning")!
    static let okay = UIColor(named: "okay")!
    static let buttons = UIColor(named: "buttons")!

    static let primaryGreen = UIColor(named: "primaryGreen")!
    static let primaryGreenText = UIColor(named: "primaryGreenText")!
    
    static var defaultBackground: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.systemBackground
        } else {
            return UIColor.white
        }
    }
}

struct Style {
    static let cornerRadius: CGFloat = 20
}
