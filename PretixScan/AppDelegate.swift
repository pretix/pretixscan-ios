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

        configStore = InMemoryConfigStore()

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

    func prefilledInMemoryConfigStore() -> ConfigStore {
        let configStore = InMemoryConfigStore()
        configStore.welcomeScreenIsConfirmed = true
        configStore.apiBaseURL = URL(string: "https://pretix.eu")
        configStore.apiToken = "54ay1m9n47gpg4szny0xx4nlif3de8hef2fx2n71wabtpfq5l2nvl94khanq4alw"
        configStore.deviceName = "Test iOS"
        configStore.organizerSlug = "iosdemo"
        configStore.deviceID = 23
        configStore.deviceUniqueSerial = "L8RQJUAI3SFU091G"
        configStore.event = Event(
            name: MultiLingualString(
                english: "Demo Conference",
                german: "Demokonferenz",
                germanInformal: "Du Demokonferenz",
                spanish: "El Conferencio",
                french: "Le Conférence Demo",
                dutch: "Demo Konferentje",
                dutchInformal: "De Demo Konferentje",
                turkish: "Konferans"
            ),
            slug: "democon",
            dateFrom: Calendar(identifier: .gregorian).date(from: DateComponents(year: 2019, month: 12, day: 19, hour: 0, minute: 0))
        )
        configStore.checkInList = CheckInList(
            identifier: 12159,
            name: "Everyone",
            allProducts: true,
            limitProducts: [],
            subEvent: nil,
            positionCount: 0,
            checkinCount: 0,
            includePending: false
        )
        configStore.debug = true
        return configStore
    }
}
