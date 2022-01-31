//
//  PXSecurityProfileTests.swift
//  PretixScanTests
//
//  Created by Konstantin Kostov on 31/01/2022.
//  Copyright © 2022 rami.io. All rights reserved.
//

import XCTest
@testable import pretixSCAN


class PXSecurityProfileTests: XCTestCase {
    
    private func defaultsKey(_ key: String) -> String {
        return "eu.pretix.pretixscan.ios.\(key)"
    }

    func testPXSecurityProfileDefaultsToFull() {
        let profile = PXSecurityProfile(rawValue: nil)
        XCTAssertEqual(profile, PXSecurityProfile.full)
    }
    
    func testPXSecurityProfileInvalidValuesParsedAsFull() {
        let value: String? = "something which is not a profile we know of"
        let profile = PXSecurityProfile(rawValue: value)
        XCTAssertEqual(profile, PXSecurityProfile.full)
    }
    
    func testPXSecurityProfileSupportsFull() {
        let profile = PXSecurityProfile(rawValue: "full")
        XCTAssertEqual(profile, PXSecurityProfile.full)
    }
    
    func testPXSecurityProfileSupportsKiosk() {
        let profile = PXSecurityProfile(rawValue: "pretixscan_online_kiosk")
        XCTAssertEqual(profile, PXSecurityProfile.kiosk)
    }
    
    func testPXSecurityProfileSupportsNoOrders() {
        let profile = PXSecurityProfile(rawValue: "pretixscan_online_noorders")
        XCTAssertEqual(profile, PXSecurityProfile.noOrders)
    }
    
    func testDefaultsConfigStoreDefaultsToFull() {
        let defaults = UserDefaults(suiteName: "testDatabase")!
        let sut = DefaultsConfigStore(defaults: defaults)
        
        XCTAssertEqual(sut.securityProfile, .full)
    }
    
    func testDefaultsConfigStoreLoadsProfileFull() {
        let defaults = UserDefaults(suiteName: "testDatabase")!
        defaults.set(PXSecurityProfile.full.rawValue, forKey: defaultsKey("securityProfile"))
        let sut = DefaultsConfigStore(defaults: defaults)
        
        XCTAssertEqual(sut.securityProfile, .full)
    }
    
    func testDefaultsConfigStoreLoadsProfileKiosk() {
        let defaults = UserDefaults(suiteName: "testDatabase")!
        defaults.set(PXSecurityProfile.kiosk.rawValue, forKey: defaultsKey("securityProfile"))
        let sut = DefaultsConfigStore(defaults: defaults)
        
        XCTAssertEqual(sut.securityProfile, .kiosk)
    }
    
    func testDefaultsConfigStoreLoadsProfileNoOrders() {
        let defaults = UserDefaults(suiteName: "testDatabase")!
        defaults.set(PXSecurityProfile.noOrders.rawValue, forKey: defaultsKey("securityProfile"))
        let sut = DefaultsConfigStore(defaults: defaults)
        
        XCTAssertEqual(sut.securityProfile, .noOrders)
    }
    
    
}
