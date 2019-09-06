//
//  PaddingView.swift
//  pretixSCAN
//
//  Created by Daniel Jilg on 15.07.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class PaddingView: UIView {
    private var contentView: UIView?

    init(enclosing contentView: UIView) {
        super.init(frame: CGRect.zero)
        self.setContent(contentView)

        layer.borderColor = Color.grayBackground.cgColor
        layer.borderWidth = 2
        layer.cornerRadius = 4
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setContent(_ newContentView: UIView) {
        contentView?.removeFromSuperview()

        newContentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(newContentView)

        newContentView.topAnchor.constraint(equalToSystemSpacingBelow: self.topAnchor, multiplier: 1).isActive = true
        self.bottomAnchor.constraint(equalToSystemSpacingBelow: newContentView.bottomAnchor, multiplier: 1).isActive = true
        newContentView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 1).isActive = true
        self.trailingAnchor.constraint(equalToSystemSpacingAfter: newContentView.trailingAnchor, multiplier: 1).isActive = true
    }
}
