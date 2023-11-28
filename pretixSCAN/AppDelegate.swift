//
//  AppDelegate.swift
//  PretixScan
//
//  Created by Daniel Jilg on 13.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit
import Sentry

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    var configStore: ConfigStore?
    var notificationManager: NotificationManager?

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
        ) -> Bool {

        // Create a Sentry client and start crash handler
#if !DEBUG
        SentrySDK.start { options in
                options.dsn = "https://b5aaf76ba03b4e778cd8370a85557263@errors.rami.io/20"
                options.debug = false // Enabled debug when first installing is always helpful
            }
#endif
        // Prevent display sleep for the entire app
        // We never want the app to turn itself off
        UIApplication.shared.isIdleTimerDisabled = true

        // ConfigStore
        configStore = DefaultsConfigStore(defaults: UserDefaults.standard)

        // NotificationManager
        if let configStore = configStore {
            notificationManager = NotificationManager(configStore: configStore)
        }

        return true
    }
}
