//
//  FeedbackPlayer.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 20/09/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation
import AVFoundation

protocol FeedbackPlayer: AnyObject {
    /// Instructs the player to play the specified audio file from the app bundle
    func playAudio(_ file: AudioFile)
}

final class FeedbackAudioPlayer: FeedbackPlayer {
    private var audioPlayer: AVAudioPlayer = AVAudioPlayer()
    
    func playAudio(_ file: AudioFile) {
        guard let filePath = Bundle.main.path(forResource: file.fileName, ofType: file.fileExtension) else {
            logger.error("Path to file \(file) was not found in application bundle.")
            return
        }
        let alertSoundUrl = URL(fileURLWithPath: filePath)
        
        do {
            // With category .playback, audio will be played directly, muting other audio, ignoring the Silent switch, ignoring screen lock.
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            logger.error("Failed activate audio session: \(error.localizedDescription)")
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: alertSoundUrl)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch {
            logger.error("Failed to play audio file: \(error.localizedDescription)")
        }
    }
}
