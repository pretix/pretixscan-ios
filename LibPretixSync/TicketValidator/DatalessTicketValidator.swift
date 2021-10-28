//
//  DatalessTicketValidator.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 28/10/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation

final class DatalessTicketValidator {
    weak var dataStore: SignedDataStore?
    
    init(dataStore: SignedDataStore) {
        self.dataStore = dataStore
    }
    
    func redeem(secret: String, event: Event) -> Result<SignedTicketData, ValidationError> {
        logger.debug("Attempting to validate ticket signature without data")
        
        guard let eventKeys = try? dataStore?.getValidKeys(for: event).get(), !eventKeys.isEmpty else {
            logger.debug("Event '\(event.slug)' has no known valid keys")
            return .failure(.noKeys)
        }
        
        if let revokedKeys = try? dataStore?.getRevokedKeys(for: event).get(), revokedKeys.contains(where: {$0.secret == secret}) {
            return .failure(.revoked)
        }
        
        guard let signedTicket = SignedTicketData(base64: secret, keys: eventKeys) else {
            return .failure(.invalid)
        }
        
        
        return .success(signedTicket)
    }
    
    enum ValidationError: Error, Hashable, Equatable, CaseIterable {
        /// The event has no valid signing keys which can be used to validate the ticket
        case noKeys
        /// The validity of the secret could not be confirmed by the event's signining keys
        case invalid
        /// The secret has been explicitly revoked for this event
        case revoked
    }
}
