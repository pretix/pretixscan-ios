//
//  TicketSignatureValidator.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 12/10/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation
import CryptoKit

struct TicketInformation: Hashable, Equatable {
    let signature: Data
    let payload: Data
}


extension TicketInformation {
    func hasValidSignature(_ validKeys: EventValidKeys) -> Bool {
        for key in validKeys.pems {
            guard let keyData = Data(base64Encoded: key), var pem = String(data: keyData, encoding: .utf8) else {
                logger.error("Failed to represent a base64 pem key.")
                continue
            }
            
            // cleanup
            pem = pem.replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----\n", with: "")
            pem = pem.replacingOccurrences(of: "-----END PUBLIC KEY-----", with: "")
            pem = pem.trimmingCharacters(in: .whitespacesAndNewlines)
            // val asn1Bytes = decodeBase64(pubKeyPEM.trim().toByteArray(Charset.defaultCharset()))
            guard let asn1Bytes = Data(base64Encoded: pem) else {
                logger.error("Failed to decode SubjectPublicKeyInfo from ASN.1 base64 encoded envelop")
                continue
            }
            
            let lastBytePosition = 43
            
            if asn1Bytes.count < lastBytePosition + 1 {
                logger.error("ASN.1 base64 encoded envelop is too short to extract key")
                continue
            }
            
            let keyBytes = asn1Bytes[12...lastBytePosition]
            do {
                let publicKey = try Curve25519.Signing.PublicKey(rawRepresentation: keyBytes)
                if publicKey.isValidSignature(self.signature, for: self.payload) {
                   return true
                }
            } catch {
                let err = error
                logger.error("Failed to construct public key from valid key pem: \(error.localizedDescription)")
                print("\(err)")
                continue
            }
        }
        // if we are here, we've exhausted all valid keys and none were valid
        return false
    }
}
