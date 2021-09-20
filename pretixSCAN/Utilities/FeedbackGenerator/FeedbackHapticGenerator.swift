//
//  FeedbackHapticGenerator.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 20/09/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import UIKit

protocol FeedbackHapticGenerator: AnyObject {
    func generate(_ type: UINotificationFeedbackGenerator.FeedbackType)
}

final class FeedbackNotificationGenerator: FeedbackHapticGenerator {
    private let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
    
    func generate(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        notificationFeedbackGenerator.notificationOccurred(type)
    }
}
