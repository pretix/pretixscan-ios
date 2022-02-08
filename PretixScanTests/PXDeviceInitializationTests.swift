//
//  PXDeviceInitializationTests.swift
//  PretixScanTests
//
//  Created by Konstantin Kostov on 08/02/2022.
//  Copyright © 2022 rami.io. All rights reserved.
//

import XCTest
@testable import pretixSCAN

class PXDeviceInitializationTests: XCTestCase {
    
    func testConfigStoreReadsVersion() {
        let defaults = UserDefaults(suiteName: "testDatabase")!
        defaults.set("8.8.8", forKey: defaultsKey(DefaultsConfigStore.Keys.publishedSoftwareVersion.rawValue))
        
        let config = DefaultsConfigStore(defaults: defaults)
        XCTAssertEqual(config.publishedSoftwareVersion, "8.8.8")
    }

    func testNeedsToUpdateWhenNoPublishedVersionSet() {
        let defaults = UserDefaults(suiteName: "testDatabase")!
        defaults.removeObject(forKey: defaultsKey(DefaultsConfigStore.Keys.publishedSoftwareVersion.rawValue))
        let config = DefaultsConfigStore(defaults: defaults)
        
        let sut = PXDeviceInitialization(config)
        sut.softwareVersion = "1.6.1"
        
        XCTAssertTrue(sut.needsToUpdate())
    }
    
    func testNeedsToUpdateWhenOlderPublishedVersionSet() {
        let defaults = UserDefaults(suiteName: "testDatabase")!
        defaults.set("1.6.1", forKey: defaultsKey(DefaultsConfigStore.Keys.publishedSoftwareVersion.rawValue))
        let config = DefaultsConfigStore(defaults: defaults)
        
        let sut = PXDeviceInitialization(config)
        sut.softwareVersion = "1.6.2"
        
        XCTAssertTrue(sut.needsToUpdate())
    }
    
    func testNeedsToUpdateWhenSamePublishedVersionSet() {
        let defaults = UserDefaults(suiteName: "testDatabase")!
        defaults.set("1.6.2", forKey: defaultsKey(DefaultsConfigStore.Keys.publishedSoftwareVersion.rawValue))
        let config = DefaultsConfigStore(defaults: defaults)
        
        let sut = PXDeviceInitialization(config)
        sut.softwareVersion = "1.6.2"
        
        XCTAssertFalse(sut.needsToUpdate())
    }
    
    func testNeedsToUpdateWhenNewerPublishedVersionSet() {
        let defaults = UserDefaults(suiteName: "testDatabase")!
        defaults.set("1.6.3", forKey: defaultsKey(DefaultsConfigStore.Keys.publishedSoftwareVersion.rawValue))
        let config = DefaultsConfigStore(defaults: defaults)
        
        let sut = PXDeviceInitialization(config)
        sut.softwareVersion = "1.6.2"
        
        XCTAssertFalse(sut.needsToUpdate())
    }

}
