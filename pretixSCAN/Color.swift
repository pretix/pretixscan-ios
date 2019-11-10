//
//  Color.swift
//  PretixScan
//
//  Created by Daniel Jilg on 26.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

struct Color {
    static let primary = #colorLiteral(red: 0.2312644422, green: 0.1089703217, blue: 0.2912759185, alpha: 1)
    static let primaryText = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    static let secondary = #colorLiteral(red: 0.4978353977, green: 0.3521931767, blue: 0.567596674, alpha: 1)
    static let grayBackground = #colorLiteral(red: 0.972464025, green: 0.9726033807, blue: 0.9724336267, alpha: 1)
    static let error = #colorLiteral(red: 0.8258044124, green: 0.3749413788, blue: 0.3758454323, alpha: 1)
    static let warning = #colorLiteral(red: 0.9982002378, green: 0.7056498528, blue: 0.1012035981, alpha: 1)
    static let okay = #colorLiteral(red: 0.3154402673, green: 0.6320772767, blue: 0.4040964842, alpha: 1)
    static let buttons = #colorLiteral(red: 0.4978353977, green: 0.3521931767, blue: 0.567596674, alpha: 1)

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
