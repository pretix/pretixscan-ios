//
//  TicketStatusSegue.swift
//  PretixScan
//
//  Created by Daniel Jilg on 05.04.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit
import SwiftMessages

class TicketStatusSegue: SwiftMessagesSegue {
    override public  init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        configure(layout: .bottomCard)
        dimMode = .blur(style: .dark, alpha: 0.6, interactive: true)
        containerView.cornerRadius = Style.cornerRadius
        messageView.configureNoDropShadow()
    }
}
