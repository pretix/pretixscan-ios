//
//  APIClientReusableMediaTests.swift
//  PretixScanTests
//
//  Created by Konstantin Kostov on 14/07/2026.
//  Copyright © 2026 rami.io. All rights reserved.
//

import XCTest
@testable import pretixSCAN

/// Inspects the `URLRequest` built by `getReusableMediaTask` without firing it, so these tests never touch the network.
class APIClientReusableMediaTests: XCTestCase {
    private var configStore: DefaultsConfigStore!
    private var apiClient: APIClient!
    private let baseURL = URL(string: "https://pretix.example.org/")!

    override func setUp() {
        super.setUp()
        let defaults = UserDefaults(suiteName: "testDatabaseAPIClientReusableMedia")!
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

    private func queryItems(_ task: URLSessionDataTask?) -> [String: String] {
        guard let url = task?.originalRequest?.url,
              let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems else {
            return [:]
        }
        return Dictionary(uniqueKeysWithValues: items.map { ($0.name, $0.value ?? "") })
    }

    func testFullFetchUsesDatetimeOrdering() {
        let task = apiClient.getReusableMediaTask(completionHandler: { _ in })

        XCTAssertTrue(task?.originalRequest?.url?.absoluteString.contains("/api/v1/organizers/iosdemo/reusablemedia/") ?? false)
        let items = queryItems(task)
        XCTAssertEqual(items["ordering"], "datetime")
        XCTAssertNil(items["created_since"])
        XCTAssertNil(items["updated_since"])
        XCTAssertEqual(items["page"], "1")
    }

    func testResumedFullFetchIncludesCreatedSince() {
        let task = apiClient.getReusableMediaTask(page: 2, createdSince: "2026-01-01T00:00:00+01:00", completionHandler: { _ in })

        let items = queryItems(task)
        XCTAssertEqual(items["ordering"], "datetime")
        XCTAssertEqual(items["created_since"], "2026-01-01T00:00:00+01:00")
        XCTAssertEqual(items["page"], "2")
    }

    func testIncrementalFetchUsesUpdatedOrdering() {
        let task = apiClient.getReusableMediaTask(updatedSince: "2026-02-01T00:00:00+01:00", completionHandler: { _ in })

        let items = queryItems(task)
        XCTAssertEqual(items["ordering"], "-updated")
        XCTAssertEqual(items["updated_since"], "2026-02-01T00:00:00+01:00")
        XCTAssertNil(items["created_since"])
    }

    func testIncrementalFetchIgnoresCreatedSinceWhenUpdatedSincePresent() {
        let task = apiClient.getReusableMediaTask(createdSince: "ignored", updatedSince: "2026-02-01T00:00:00+01:00", completionHandler: { _ in })

        let items = queryItems(task)
        XCTAssertEqual(items["ordering"], "-updated")
        XCTAssertNil(items["created_since"])
    }
}
