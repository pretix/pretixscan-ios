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
        guard let urlRequest = createURLRequest(for: "/api/v1/organizers/\(organizer)/events/") else { return }

        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            if let error = self.extractedError(fromData: data, response: response, error: error) {
                completionHandler(nil, error)
                return
            }

            let pagedListResult: (list: PagedList<Event>?, error: Error?) = self.pagedList(from: data!)
            completionHandler(pagedListResult.list?.results, pagedListResult.error)
        }
        task.resume()
    }
}

// MARK: - Check In Lists
public extension APIClient {
    /// Returns a list of all check-in lists within a given event.
    public func getCheckinLists(
        forOrganizer organizer: String,
        event: Event,
        completionHandler: @escaping ([CheckInList]?, Error?) -> Void) {

        guard let urlRequest = createURLRequest(for: "/api/v1/organizers/\(organizer)/events/\(event.slug)/checkinlists/") else { return }

        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            if let error = self.extractedError(fromData: data, response: response, error: error) {
                completionHandler(nil, error)
                return
            }

            let pagedListResult: (list: PagedList<CheckInList>?, error: Error?) = self.pagedList(from: data!)
            completionHandler(pagedListResult.list?.results, pagedListResult.error)
        }
        task.resume()
    }
}

// MARK: - Common
private extension APIClient {
    func createURLRequest(for pathComponent: String) -> URLRequest? {
        guard let baseURL = configStore.apiBaseURL else {
            print("Please set the APIClient's configStore.apiBaseURL property before calling this function. ")
            return nil
        }

        guard let apiToken = configStore.apiToken else {
            print("Please set the APIClient's configStore.apiToken property before calling this function. ")
            return nil
        }

        let url = baseURL.appendingPathComponent(pathComponent)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HttpMethod.GET
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Device \(apiToken)", forHTTPHeaderField: "Authorization")
        urlRequest.httpBody = nil
        return urlRequest
    }

    func extractedError(fromData data: Data?, response: URLResponse?, error: Error?) -> Error? {
        guard error == nil else {
            return error
        }

        guard data != nil else {
            return Errors.EmptyResponse()
        }

        guard let httpURLResponse = response as? HTTPURLResponse else {
            return Errors.NonHTTPResponse()
        }

        guard httpURLResponse.statusCode == 200 else {
            switch httpURLResponse.statusCode {
            case 401:
                return Errors.Unauthorized()
            case 403:
                return Errors.Forbidden()
            default:
                return Errors.UnknownStatusCode()
            }
        }

        return nil
    }

    func pagedList<T: Codable>(from data: Data) -> (list: PagedList<T>?, error: Error?) {
        do {
            return (try self.jsonDecoder.decode(PagedList<T>.self, from: data), nil)
        } catch let jsonError {
            return (nil, jsonError)
        }
    }
}
