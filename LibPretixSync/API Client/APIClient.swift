//
//  APIClient.swift
//  PretixScan
//
//  Created by Daniel Jilg on 14.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

/// Communicates with the pretix API.
///
/// ## New Connections
/// - Init with a config Store
/// - Set the config store's apiBaseURL
/// - Then call initialize with a DeviceInitializationRequest to obtain an API Token
public class APIClient {
    // MARK: - Public Properties
    public var configStore: ConfigStore
    public var isReadyToCommunicate: Bool { return configStore.isAPIConfigured }

    // MARK: - Private Properties
    private let jsonEncoder: JSONEncoder = {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = .iso8601
        return jsonEncoder
    }()

    private let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .iso8601
        return jsonDecoder
    }()

    private let session = URLSession.shared

    // MARK: - Initialization
    init(configStore: ConfigStore) {
        self.configStore = configStore
    }
}

// MARK: - Devices
public extension APIClient {
    public func initialize(_ initializationRequest: DeviceInitializationRequest, completionHandler: @escaping (Error?) -> Void) {
        guard let baseURL = configStore.apiBaseURL else {
            print("Please set the APIClient's configStore.apiBaseURL property before calling this function. ")
            return
        }

        let url = baseURL.appendingPathComponent("/api/v1/device/initialize")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HttpMethod.POST
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // swiftlint:disable:next force_try
        urlRequest.httpBody = try! jsonEncoder.encode(initializationRequest)

        let task = session.dataTask(with: urlRequest) { (data, _, error) in
            guard error == nil else {
                completionHandler(error)
                return
            }

            guard let responseData = data else {
                completionHandler(Errors.EmptyResponse())
                return
            }

            let initializationResponse: DeviceInitializationResponse
            do {
                initializationResponse = try self.jsonDecoder.decode(DeviceInitializationResponse.self, from: responseData)
            } catch let jsonError {
                completionHandler(jsonError)
                return
            }

            self.configStore.apiToken = initializationResponse.apiToken
            self.configStore.deviceID = initializationResponse.deviceID
            self.configStore.deviceName = initializationResponse.name
            self.configStore.deviceUniqueSerial = initializationResponse.uniqueSerial
            self.configStore.organizerSlug = initializationResponse.organizer

            completionHandler(nil)
        }

        task.resume()
    }
}

// MARK: - Events
public extension APIClient {
    /// Returns a list of all events within a given organizer the authenticated user/token has access to.
    public func getEvents(forOrganizer organizer: String, completionHandler: @escaping ([Event]?, Error?) -> Void) {
        guard let baseURL = configStore.apiBaseURL else {
            print("Please set the APIClient's configStore.apiBaseURL property before calling this function. ")
            return
        }

        guard let apiToken = configStore.apiToken else {
            print("Please set the APIClient's configStore.apiToken property before calling this function. ")
            return
        }

        guard let organizerSlug = configStore.organizerSlug else {
            print("Please set the APIClient's configStore.organizerSlug property before calling this function. ")
            return
        }

        let url = baseURL.appendingPathComponent("/api/v1/organizers/\(organizerSlug)/events/")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HttpMethod.GET
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Device \(apiToken)", forHTTPHeaderField: "Authorization")
        urlRequest.httpBody = nil

        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil else {
                completionHandler(nil, error)
                return
            }

            guard let responseData = data else {
                completionHandler(nil, Errors.EmptyResponse())
                return
            }

            guard let httpURLResponse = response as? HTTPURLResponse else {
                completionHandler(nil, Errors.NonHTTPResponse())
                return
            }

            guard httpURLResponse.statusCode == 200 else {
                switch httpURLResponse.statusCode {
                case 401:
                    completionHandler(nil, Errors.Unauthorized())
                case 403:
                    completionHandler(nil, Errors.Forbidden())
                default:
                    completionHandler(nil, Errors.UnknownStatusCode())
                }
                return
            }

            let pagedEventList: PagedList<Event>
            do {
                pagedEventList = try self.jsonDecoder.decode(PagedList<Event>.self, from: responseData)
            } catch let jsonError {
                completionHandler(nil, jsonError)
                return
            }

            completionHandler(pagedEventList.results, nil)
        }

        task.resume()
    }
}
