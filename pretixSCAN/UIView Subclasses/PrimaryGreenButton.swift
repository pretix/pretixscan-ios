//
//  PrimaryGreenButton.swift
//  PrimaryGreenButton
//
//  Created by Konstantin Kostov on 17/08/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation
import UIKit

class PrimaryGreenButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        backgroundColor = PXColor.primaryGreen
        tintColor = PXColor.primaryGreenText
        setTitleColor(PXColor.primaryGreenText, for: .normal)
        layer.cornerRadius = Style.cornerRadius
        titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        contentEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        alpha = isEnabled ? 1.0 : 0.6
    }
}
