//
//  LoadingIndicator.swift
//  PretixScan
//
//  Created by Daniel Jilg on 02.04.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

private var globalBackgroundView: UIView?
private var globalContainerView: UIView?
private var globalYAnchor: NSLayoutConstraint?
private let viewHeight: CGFloat = 160

extension UIViewController {
    func showLoadingIndicator(over theView: UIView) {
        // Background View
        let backgroundView = UIView.init(frame: theView.bounds)
        backgroundView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
        backgroundView.layer.opacity = 0

        // Container View
        let containerView = UIView.init(frame: CGRect.zero)
        containerView.backgroundColor = UIColor.white
        containerView.layer.cornerRadius = Style.cornerRadius

        // Activity Indicator
        let activityIndicator = UIActivityIndicatorView.init(style: .gray)
        activityIndicator.startAnimating()

        DispatchQueue.main.async {
            // Adding Subviews
            theView.addSubview(backgroundView)
            backgroundView.addSubview(containerView)
            containerView.addSubview(activityIndicator)

            // Constraints
            containerView.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            containerView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
            let yAnchor = containerView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: viewHeight)
            yAnchor.isActive = true
            containerView.widthAnchor.constraint(equalTo: theView.widthAnchor, multiplier: 0.7).isActive = true
            containerView.heightAnchor.constraint(equalToConstant: viewHeight).isActive = true
            activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
            activityIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true

            theView.layoutIfNeeded()

            // Animate In
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
                yAnchor.constant = -40
                theView.layoutIfNeeded()
                backgroundView.layer.opacity = 1
            })

            globalBackgroundView = backgroundView
            globalContainerView = containerView
            globalYAnchor = yAnchor
        }
    }

    func hideLoadingIndicator() {
        DispatchQueue.main.async {
            // Animate Out
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
                globalYAnchor?.constant = viewHeight
                globalBackgroundView?.layoutIfNeeded()
                globalBackgroundView?.layer.opacity = 0
            })

            globalBackgroundView?.removeFromSuperview()
            globalBackgroundView = nil
        }
    }
}
