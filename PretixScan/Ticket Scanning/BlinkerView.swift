//
//  BlinkerView.swift
//  pretixSCAN
//
//  Created by Daniel Jilg on 01.06.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class BlinkerView: UIView {
    private var blinkTimer: Timer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        blinkTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            self.alpha = self.alpha == 0 ? 1 : 0
        }
    }
}
