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
    
    
    // MARK: - Endpoit tests
    private func assertUrlMatchesSingleEndpointInProfile(url: String, method: String, profile: PXSecurityProfile, expectedName: String) {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = method
        
        let endpoints = PXSecurityProfileRequestValidator.matchingEndpoints(for: request, profile: profile)
        
        XCTAssertEqual(endpoints.count, 1, "The endpoint url for \(expectedName) must be matched exactly once. Did you register a regular expression for it?")
        XCTAssertEqual(endpoints[0].0, method)
        XCTAssertEqual(endpoints[0].1, expectedName)
    }
    
    /// This test validates that all URLs have a valid regular expression resulting in a unique endpoint match. The expected name is a string constant usually shared with the server by convention.
    func testProfilePretixScanV1Endpoints() {
    
        assertUrlMatchesSingleEndpointInProfile(url: "https://pretix.eu/api/v1/organizers/iosdemo/events/?page=1&ordering=datetime", method: "GET", profile: .pretixscan, expectedName: "api-v1:event-list")
        assertUrlMatchesSingleEndpointInProfile(url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/", method: "GET", profile: .pretixscan, expectedName: "api-v1:event-detail")
        assertUrlMatchesSingleEndpointInProfile(url: "https://pretix.eu/api/v1/organizers/iosdemo/events/democon/subevents/", method: "GET", profile: .pretixscan, expectedName: "api-v1:subevent-list")
    
    }
}
