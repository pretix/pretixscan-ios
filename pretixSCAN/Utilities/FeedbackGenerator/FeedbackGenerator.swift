//
//  FeedbackGenerator.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 16/09/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation

public protocol FeedbackGenerator: AnyObject {
    /// Generate feedback
    func announce(_ type: FeedbackType)
    /// Generate feedback based on the provided redemption reponse and request error
    func announce(redemptionResponse: RedemptionResponse?, _ error: Error?, _ exitMode: Bool)
    /// Change the mode of the feedback generator. Use this method to toggle between offline and online announcements
    func setMode(_ mode: FeedbackMode) -> Self
    func setPlaySounds( _ playSounds: Bool) -> Self
}


public enum FeedbackType: String, Equatable, Hashable, CaseIterable, CustomStringConvertible {
    /// QR code was recognized by the camera
    case didScanQrCode
    /// Validation result is "OK" and we're in entry mode
    case validEntry
    /// Validation result is "OK", requires attention flag is set and we're in entry mode
    case validEntryRequiresAttention
    /// Validation result is "OK" and we're in exit mode
    case validExit
    /// Validation result is *not* "OK"
    case invalid
    
    public var description: String {
        self.rawValue
    }
}

enum AudioFile: String, Equatable, Hashable, CaseIterable, CustomStringConvertible {
    case attention
    case beep
    case enter
    case error
    case exit
    
    var fileName: String {
        rawValue
    }
    
    var fileExtension: String {
        "m4a"
    }
    
    var description: String {
        return "\(fileName).\(fileExtension)"
    }
}

public enum FeedbackMode: String, Equatable, Hashable, CaseIterable, CustomStringConvertible {
    /// In offline mode we skip feedback for scanned QR-codes
    case offline
    case online
    
    public var description: String {
        self.rawValue
    }
}
