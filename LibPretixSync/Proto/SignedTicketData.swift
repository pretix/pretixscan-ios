//
//  SignedTicketData.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 12/10/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation


struct SignedTicketData: Hashable, Equatable {
    let seed: String
    let item: Identifier
    let variation: Identifier
    let subEvent: Identifier
    let validFrom: Date?
    let validUntil: Date?
}

extension SignedTicketData {
    static let version: UInt8 = 0x01
    
    init?(base64: String, keys: [EventValidKey]) {
        self.init(base64: base64, keys: EventValidKeys(pems: keys.map({$0.secret})))
    }
    
    init?(base64: String, keys: EventValidKeys) {
        let reversed = String(base64.reversed())
        guard let data = Data(base64Encoded: reversed) else {
            logger.debug("Invalid base64 encoded value")
            return nil
        }
        
        if data.isEmpty {
            logger.debug("base64 value was an empty byte array")
            return nil
        }
        
        if data[0] != Self.version {
            logger.debug("base64 value version mismatch, expected \(Self.version) but got '\(data[0])'")
            return nil
        }
        
        if data.count < 5 {
            logger.debug("base64 value has insufficient leading control bytes")
            return nil
        }
        
        let payloadLength = Int(data[1]) << 2 + Int(data[2])
        let signatureLength = Int(data[3]) << 2 + Int(data[4])
        
        if data.count < (5 + signatureLength) {
            logger.debug("base64 value has insufficient leading signature bytes")
            return nil
        }
        
        let payload = data[5..<(5 + payloadLength)]
        let signature = data[(5 + payloadLength)..<(5 + payloadLength + signatureLength)]
        let ticketInformation = TicketInformation(signature: signature, payload: payload)
        
        if !ticketInformation.hasValidSignature(keys) {
            logger.debug("base64 signature is not valid")
            return nil
        }
        
        do {
            let ticket = try Ticket(contiguousBytes: payload)
            self = SignedTicketData(
                seed: ticket.seed,
                item: Identifier(ticket.item),
                variation: Identifier(ticket.variation),
                subEvent: Identifier(ticket.subevent),
                validFrom: ticket.hasValidFromUnixTime ? Date(timeIntervalSince1970: TimeInterval(ticket.validFromUnixTime)) : nil,
                validUntil: ticket.hasValidUntilUnixTime ? Date(timeIntervalSince1970: TimeInterval(ticket.validUntilUnixTime)) : nil)
        } catch {
            logger.error("Failed to decode protobuf Ticket payload: \(error.localizedDescription)")
            return nil
        }
    }
}
