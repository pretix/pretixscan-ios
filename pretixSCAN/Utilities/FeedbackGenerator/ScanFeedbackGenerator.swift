//
//  OnlineFeedbackGenerator.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 16/09/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import UIKit
import AVFoundation

/// Coordinates user feedback like playing a sound or vibration (haptic feedback)
final class ScanFeedbackGenerator: FeedbackGenerator {
    private var mode: FeedbackMode
    private var playSounds: Bool = false
    private var player: FeedbackPlayer = FeedbackAudioPlayer()
    private var hapticGenerator: FeedbackHapticGenerator = FeedbackNotificationGenerator()
    
    init(_ isOnlineMode: Bool) {
        mode = isOnlineMode ? .online : .offline
    }
    
    init(_ mode: FeedbackMode = .online) {
        self.mode = mode
    }
    
    init(_ player: FeedbackPlayer, hapticGenerator: FeedbackHapticGenerator) {
        self.player = player
        self.hapticGenerator = hapticGenerator
        self.mode = .online
    }
    
    
    func setMode(_ mode: FeedbackMode) -> Self {
        self.mode = mode
        return self
    }
    
    func setPlaySounds(_ playSounds: Bool) -> Self {
        self.playSounds = playSounds
        return self
    }
    
    private func performHapticNotification(ofType type: UINotificationFeedbackGenerator.FeedbackType) {
        hapticGenerator.generate(type)
    }
    
    /// Generates user feedback appropriate for the provided `RedemptionResponse`
    func announce(redemptionResponse: RedemptionResponse?, _ error: Error?, _ exitMode: Bool) {
        if error != nil {
            logger.debug("Announcing .invalid due to network error.")
            announce(.invalid)
            return
        }
        
        guard let redemptionResponse = redemptionResponse else {
            logger.debug("Ignoring announcement for nil redemptionResponse")
            return
        }
        
        switch redemptionResponse.status {
        case .redeemed:
            announce(exitMode ? .validExit : .validEntry)
        case .incomplete:
            logger.debug("Skipping announcement due to incomplete.")
            performHapticNotification(ofType: .warning)
        case .error:
            announce(.invalid)
        }
    }
    
    /// Generates user feedback of the specified `FeedbackType`
    func announce(_ type: FeedbackType) {
        logger.debug("📣 \(self.mode == .online ? "🌐" : "🔌") Feedback type \(type)")
        switch type {
        case .didScanQrCode:
            if mode == .online {
                playSound(.beep)
            }
        case .validEntry:
            performHapticNotification(ofType: .success)
            playSound(.enter)
        case .validExit:
            performHapticNotification(ofType: .success)
            playSound(.exit)
        case .invalid:
            performHapticNotification(ofType: .error)
            playSound(.error)
        }
    }
    
    func playSound(_ file: AudioFile) {
        if !playSounds {
            logger.debug("Skipping audio playback")
            return
        }
        player.playAudio(file)
    }
}


