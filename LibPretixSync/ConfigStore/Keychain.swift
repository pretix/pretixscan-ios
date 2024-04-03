//
//  Keychain.swift
//  Tink AB
//
//  Created by Lukas Lipka on 21/08/2018.
//  Copyright © 2018 Tink AB. All rights reserved.
//
import Foundation
import Security

private let kSecClassValue = String(kSecClass)
private let kSecAttrAccountValue = String(kSecAttrAccount)
private let kSecValueDataValue = String(kSecValueData)
private let kSecClassGenericPasswordValue = String(kSecClassGenericPassword)
private let kSecAttrServiceValue = String(kSecAttrService)
private let kSecMatchLimitValue = String(kSecMatchLimit)
private let kSecReturnDataValue = String(kSecReturnData)
private let kSecMatchLimitOneValue = String(kSecMatchLimitOne)

public struct Keychain {
    private init() {}

    public static func set(password: String, account: String, service: String) {
        print("🔑 Updating token in Keychain")
        // purge the store from any leaked tokens
        delete(account: account, service: service)
        
        // create a new keychain record
        print("🔑 Creating a token in Keychain")
        guard let data = password.data(using: .utf8) else { return }
        let query: [String: Any] = [
            kSecClassValue: kSecClassGenericPasswordValue,
            kSecAttrServiceValue: service,
            kSecAttrAccountValue: account,
            kSecValueDataValue: data,
            kSecAttrSynchronizable as String: kCFBooleanFalse!,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        SecItemAdd(query as CFDictionary, nil)
    }
    public static func get(account: String, service: String) -> String? {
        let query: [String: Any] = [
            kSecClassValue: kSecClassGenericPasswordValue,
            kSecAttrServiceValue: service,
            kSecAttrAccountValue: account,
            kSecReturnDataValue: kCFBooleanTrue as Any,
            kSecMatchLimitValue: kSecMatchLimitOneValue
        ]

        var buffer: AnyObject?
        if SecItemCopyMatching(query as CFDictionary, &buffer) == errSecSuccess {
            if let data = buffer as? Data {
                let token = String(data: data, encoding: .utf8)
                print("🔑 Reading token: \(token != nil)")
                return token
            }
        }

        return nil
    }

    public static func delete(account: String, service: String) {
        print("🔑 Purging all tokens")
        
        let query: [String: Any] = [
            kSecClassValue: kSecClassGenericPasswordValue,
            kSecAttrServiceValue: service,
            kSecAttrAccountValue: account
        ]

        let status = SecItemDelete(query as CFDictionary)
        if !(status == errSecSuccess || status == errSecItemNotFound) {
            EventLogger.log(event: "Failed to remove keychain item: \(String(describing: status))", category: .configuration, level: .warning, type: .error)
        }
    }
}
