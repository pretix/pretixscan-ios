//
//  APIClient.swift
//  PretixScan
//
//  Created by Daniel Jilg on 14.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

/// Manages requests to and responses from the Pretix REST API.
///
/// ## New Connections
/// - Init with a config Store
/// - Set the config store's apiBaseURL
/// - Then call initialize with a DeviceInitializationRequest to obtain an API Token
public class APIClient {
    // MARK: - Public Properties
    private var configStore: ConfigStore

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
    init?(configStore: ConfigStore) {
        if !configStore.isAPIConfigured { return nil }
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
                completionHandler(APIErrors.emptyResponse)
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
    public func getEvents(completionHandler: @escaping ([Event]?, Error?) -> Void) {
        do {
            let organizer = try getOrganizerSlug()
            let urlRequest = try createURLRequest(for: "/api/v1/organizers/\(organizer)/events/")
            let task = session.dataTask(with: urlRequest) { (data, response, error) in
                if let error = self.checkResponse(data: data, response: response, error: error) {
                    completionHandler(nil, error)
                    return
                }

                let pagedListResult: (list: PagedList<Event>?, error: Error?) = self.pagedList(from: data!)
                completionHandler(pagedListResult.list?.results, pagedListResult.error)
            }
            task.resume()
        } catch {
            completionHandler(nil, error)
        }
    }
}

// MARK: - Check In Lists
public extension APIClient {
    /// Returns a list of all check-in lists within a given event.
    public func getCheckinLists(completionHandler: @escaping ([CheckInList]?, Error?) -> Void) {
        do {
            let organizer = try getOrganizerSlug()
            let event = try getEvent()
            let urlPath = "/api/v1/organizers/\(organizer)/events/\(event.slug)/checkinlists/"
            let urlRequest = try createURLRequest(for: urlPath)

            let task = session.dataTask(with: urlRequest) { (data, response, error) in
                if let error = self.checkResponse(data: data, response: response, error: error) {
                    completionHandler(nil, error)
                    return
                }

                let pagedListResult: (list: PagedList<CheckInList>?, error: Error?) = self.pagedList(from: data!)
                completionHandler(pagedListResult.list?.results, pagedListResult.error)
            }
            task.resume()

        } catch {
            completionHandler(nil, error)
        }

    }
}

// MARK: - Search
public extension APIClient {
    public func getSearchResults(query: String, completionHandler: @escaping ([OrderPosition]?, Error?) -> Void) {
        do {
            let organizer = try getOrganizerSlug()
            let event = try getEvent()
            let url = try createURL(for: "/api/v1/organizers/\(organizer)/events/\(event.slug)/orderpositions/")

            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            urlComponents?.queryItems = [URLQueryItem(name: "search", value: query)]
            guard let urlComponentsURL = urlComponents?.url else {
                throw APIErrors.couldNotCreateURL
            }
            let urlRequest = try createURLRequest(for: urlComponentsURL)

            let task = session.dataTask(with: urlRequest) { (data, response, error) in
                if let error = self.checkResponse(data: data, response: response, error: error) {
                    completionHandler(nil, error)
                    return
                }

                let pagedListResult: (list: PagedList<OrderPosition>?, error: Error?) = self.pagedList(from: data!)
                completionHandler(pagedListResult.list?.results, pagedListResult.error)
            }
            task.resume()

        } catch {
            completionHandler(nil, error)
        }
    }
}

// MARK: - Accessing Properties
private extension APIClient {
    func getOrganizerSlug() throws -> String {
        guard let organizer = configStore.organizerSlug else {
            throw APIErrors.notConfigured(message:
                "APIClient's configStore.organizerSlug property must be set before calling this function."
            )
        }

        return organizer
    }

    func getEvent() throws -> Event {
        guard let event = configStore.event else {
            throw APIErrors.notConfigured(message: "APIClient's configStore.event property must be set before calling this function.")
        }

        return event
    }
}

// MARK: - Creating Requests
private extension APIClient {
    func createURLRequest(for pathComponent: String) throws -> URLRequest {
        let url = try createURL(for: pathComponent)
        let urlRequest = try createURLRequest(for: url)
        return urlRequest
    }

    func createURL(for pathComponent: String) throws -> URL {
        guard let baseURL = configStore.apiBaseURL else {
            throw APIErrors.notConfigured(message: "APIClient's configStore.apiBaseURL property must be set before calling this function.")
        }

        return baseURL.appendingPathComponent(pathComponent)
    }

    func createURLRequest(for url: URL) throws -> URLRequest {
        guard let apiToken = configStore.apiToken else {
            throw APIErrors.notConfigured(message: "APIClient's configStore.apiToken property must be set before calling this function.")
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HttpMethod.GET
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Device \(apiToken)", forHTTPHeaderField: "Authorization")
        urlRequest.httpBody = nil
        return urlRequest
    }

    func checkResponse(data: Data?, response: URLResponse?, error: Error?) -> Error? {
        guard error == nil else {
            return error
        }

        guard data != nil else {
            return APIErrors.emptyResponse
        }

        guard let httpURLResponse = response as? HTTPURLResponse else {
            return APIErrors.nonHTTPResponse
        }

        guard httpURLResponse.statusCode == 200 else {
            switch httpURLResponse.statusCode {
            case 401:
                return APIErrors.unauthorized
            case 403:
                return APIErrors.forbidden
            default:
                return APIErrors.unknownStatusCode(statusCode: httpURLResponse.statusCode)
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
