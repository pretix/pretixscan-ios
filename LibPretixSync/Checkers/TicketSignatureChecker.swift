//
//  DatalessTicketValidator.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 28/10/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation

final class TicketSignatureChecker {
    weak var dataStore: DatalessDataStore?
    
    init(dataStore: DatalessDataStore) {
        self.dataStore = dataStore
    }
    
    func redeem(secret: String, event: Event) -> Result<SignedTicketData, ValidationError> {
        logger.debug("Attempting to validate ticket signature without data")
        
        // is the event configured to decode keys
        guard let eventKeys = try? dataStore?.getValidKeys(for: event).get(), !eventKeys.isEmpty else {
            logger.debug("Event '\(event.slug)' has no known valid keys")
            return .failure(.noKeys)
        }
        
        // is the ticket secret on the revokation list
        if let revokedKeys = try? dataStore?.getRevokedKeys(for: event).get(), revokedKeys.contains(where: {$0.secret == secret}) {
            return .failure(.revoked)
        }
        
        // if the ticket secret is blocked
        if let blockedKeys = try? dataStore?.getBlockedKeys(for: event).get(), blockedKeys.contains(where: {$0.secret == secret && $0.blocked}) {
            return .failure(.blocked)
        }
        
        // does the secret decode with available keys
        guard let signedTicket = SignedTicketData(base64: secret, keys: eventKeys) else {
            return .failure(.invalid)
        }
        
        
        return .success(signedTicket)
    }
    
    enum ValidationError: Error, Hashable, Equatable {
        /// The event has no valid signing keys which can be used to validate the ticket
        case noKeys
        /// The validity of the secret could not be confirmed by the event's signining keys
        case invalid
        /// The secret has been explicitly revoked for this event
        case revoked
        /// The secret has been blocked for this event
        case blocked
    }
}
