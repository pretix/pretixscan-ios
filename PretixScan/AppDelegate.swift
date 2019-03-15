//
//  AppDelegate.swift
//  PretixScan
//
//  Created by Daniel Jilg on 13.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var configStore: ConfigStore?
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
        ) -> Bool {

        let inMemoryConfigStore = InMemoryConfigStore()

        /*
        ----------------------------------------
        InMemoryConfigStore
        ----------------------------------------
        welcomeScreenIsConfirmed: true
        isAPIConfigured:          true
        apiBaseURL:               Optional(https://pretix.eu)
        apiToken:                 1hmo8vtjajk8wwgwzcgz3xtuzswz63132q03e486xmaohou4oyku3y114jpwyd2y
        deviceName:               Test iOS Simulator
        organizerName:            iosdemo
        deviceID:                 Optional(7)
        deviceUniqueSerial:       H9AC2B59AOO293Y0
        ----------------------------------------
        */
        inMemoryConfigStore.welcomeScreenIsConfirmed = true
        inMemoryConfigStore.apiBaseURL = URL(string: "https://pretix.eu")
        inMemoryConfigStore.apiToken = "1hmo8vtjajk8wwgwzcgz3xtuzswz63132q03e486xmaohou4oyku3y114jpwyd2y"
        inMemoryConfigStore.deviceName = "Test iOS Simulator"
        inMemoryConfigStore.organizerName = "iosdemo"
        inMemoryConfigStore.deviceID = 7
        inMemoryConfigStore.deviceUniqueSerial = "H9AC2B59AOO293Y0"

        inMemoryConfigStore.debug = true

        configStore = inMemoryConfigStore

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {

    }

    func applicationDidEnterBackground(_ application: UIApplication) {

    }

    func applicationWillEnterForeground(_ application: UIApplication) {

    }

    func applicationDidBecomeActive(_ application: UIApplication) {

    }

    func applicationWillTerminate(_ application: UIApplication) {

    }
}
