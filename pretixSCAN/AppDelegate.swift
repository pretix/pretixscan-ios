//
//  AppDelegate.swift
//  PretixScan
//
//  Created by Daniel Jilg on 13.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit
import Sentry

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var configStore: ConfigStore?
    var notificationManager: NotificationManager?

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
        ) -> Bool {

        // Create a Sentry client and start crash handler
        do {
            Client.shared = try Client(dsn: "https://b5aaf76ba03b4e778cd8370a85557263@errors.rami.io/20")
            try Client.shared?.startCrashHandler()
        } catch let error {
            print("\(error)")
            // Wrong DSN or KSCrash not installed
        }

        // Prevent display sleep for the entire app
        // We never want the app to turn itself off
        UIApplication.shared.isIdleTimerDisabled = true

        // ConfigStore
        configStore = DefaultsConfigStore(defaults: UserDefaults.standard)

        // NotificationManager
        if let configStore = configStore {
            notificationManager = NotificationManager(configStore: configStore)
        }

        // Setup Appearance
        UIButton.appearance().tintColor = Color.buttons
        UIProgressView.appearance().tintColor = Color.buttons
        UIActivityIndicatorView.appearance().tintColor = Color.buttons

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
