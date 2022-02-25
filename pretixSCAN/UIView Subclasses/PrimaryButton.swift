//
//  PrimaryButton.swift
//  PretixScan
//
//  Created by Daniel Jilg on 02.04.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class PrimaryButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1.0 : 0.6
        }
    }

    private func setup() {
        backgroundColor = PXColor.primary
        tintColor = PXColor.primaryText
        setTitleColor(PXColor.primaryText, for: .normal)
        layer.cornerRadius = Style.cornerRadius
        titleLabel?.font = UIFont.systemFont(ofSize: 17)
        contentEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        alpha = isEnabled ? 1.0 : 0.6
    }
}
