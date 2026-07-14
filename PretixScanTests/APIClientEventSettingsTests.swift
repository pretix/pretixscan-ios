//
//  APIClientEventSettingsTests.swift
//  PretixScanTests
//
//  Created by Konstantin Kostov on 15/07/2026.
//  Copyright © 2026 rami.io. All rights reserved.
//

import XCTest
@testable import pretixSCAN

class APIClientEventSettingsTests: XCTestCase {
    private var configStore: DefaultsConfigStore!
    private var apiClient: APIClient!
    private let baseURL = URL(string: "https://pretix.example.org/")!

    override func setUp() {
        super.setUp()
        let defaults = UserDefaults(suiteName: "testDatabaseAPIClientEventSettings")!
        configStore = DefaultsConfigStore(defaults: defaults)
        configStore.apiBaseURL = baseURL
        configStore.organizerSlug = "iosdemo"
        configStore.securityProfile = .full
        Keychain.set(password: "test-token", account: baseURL.absoluteString, service: baseURL.absoluteString)
        apiClient = APIClient(configStore: configStore)
    }

    override func tearDown() {
        Keychain.delete(account: baseURL.absoluteString, service: baseURL.absoluteString)
        apiClient = nil
        configStore = nil
        super.tearDown()
    }

    func testRequestsTheEventSettingsEndpoint() {
        let event = Event(name: MultiLingualString.english("Test Event"), slug: "democon",
                          dateFrom: Date(), dateTo: Date(), dateAdmission: Date(), hasSubEvents: false, validKeys: nil,
                          timezone: Calendar.current.timeZone.identifier)

        let task = apiClient.getEventSettingsTask(event: event, completionHandler: { _ in })

        XCTAssertTrue(task?.originalRequest?.url?.absoluteString.contains("/api/v1/organizers/iosdemo/events/democon/settings/") ?? false)
        XCTAssertEqual(task?.originalRequest?.httpMethod, "GET")
    }
}
