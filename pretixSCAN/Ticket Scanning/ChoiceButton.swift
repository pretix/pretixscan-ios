//
//  ChoiceButton.swift
//  pretixSCAN
//
//  Created by Daniel Jilg on 15.07.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class ChoiceButton: UIButton {
    override var isSelected: Bool { didSet { update() }}
    override var isHighlighted: Bool { didSet { updateHighlight() }}

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        backgroundColor = UIColor(cgColor: Color.secondary.cgColor.copy(alpha: 0.5)!)
        layer.cornerRadius = 4
        layer.borderColor = Color.secondary.cgColor
        layer.borderWidth = 2

        titleLabel?.numberOfLines = 2
        titleLabel?.lineBreakMode = .byWordWrapping
        titleLabel?.setContentCompressionResistancePriority(.required, for: .vertical)

        let height = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: titleLabel, attribute: .height,
                                        multiplier: 1, constant: 20)
        addConstraint(height)
    }

    private func update() {
        UIView.animate(withDuration: 0.25) {
            if self.isSelected {
                self.backgroundColor = UIColor(cgColor: Color.secondary.cgColor.copy(alpha: 0.9)!)
            } else {
                self.backgroundColor = UIColor(cgColor: Color.secondary.cgColor.copy(alpha: 0.5)!)
            }
        }
    }

    private func updateHighlight() {
        if isHighlighted {
            backgroundColor = Color.secondary
        } else {
            update()
        }
    }
}
