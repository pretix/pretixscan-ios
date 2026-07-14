//
//  APIClient+ReusableMedia.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 14/07/2026.
//  Copyright © 2026 rami.io. All rights reserved.
//

import Foundation

extension APIClient {
    /// Returns a task that retrieves `ReusableMedium`s from the organizer-level `/reusablemedia/` endpoint
    /// and calls the completion handler for each page, once run.
    ///
    func getReusableMediaTask(page: Int = 1, createdSince: String? = nil, updatedSince: String? = nil,
                              completionHandler: @escaping (Result<PagedList<ReusableMedium>, Error>) -> Void) -> URLSessionDataTask? {
        do {
            let organizer = try getOrganizerSlug()
            let url = try createURL(for: "/api/v1/organizers/\(organizer)/reusablemedia/")

            guard let urlComponentsURL = createReusableMediaURLComponents(
                url: url, page: page, createdSince: createdSince, updatedSince: updatedSince)?.url else {
                throw APIError.couldNotCreateURL
            }

            let urlRequest = try createURLRequest(for: urlComponentsURL)

            if !isAllowed(request: urlRequest) {
                completionHandler(.failure(APIError.notAllowed))
                return nil
            }

            let task = session.dataTask(with: urlRequest) { (data, response, error) in
                if let error = self.checkResponse(data: data, response: response, error: error) {
                    completionHandler(.failure(error))
                    return
                }

                guard let data = data else {
                    completionHandler(.failure(APIError.emptyResponse))
                    return
                }

                do {
                    var pagedList = try self.jsonDecoder.decode(PagedList<ReusableMedium>.self, from: data)
                    pagedList.generatedAt = (response as? HTTPURLResponse)?.find(header: "X-Page-Generated")

                    completionHandler(.success(pagedList))

                    if pagedList.next != nil {
                        self.getReusableMediaTask(page: page + 1, createdSince: createdSince, updatedSince: updatedSince,
                                                  completionHandler: completionHandler)?.resume()
                    }
                } catch {
                    completionHandler(.failure(error))
                }
            }
            return task
        } catch {
            completionHandler(.failure(error))
            return nil
        }
    }

    private func createReusableMediaURLComponents(url: URL, page: Int, createdSince: String?, updatedSince: String?) -> URLComponents? {
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        var queryItems = [URLQueryItem(name: "page", value: "\(page)")]

        if let updatedSince = updatedSince {
            queryItems.append(URLQueryItem(name: "ordering", value: "-updated"))
            queryItems.append(URLQueryItem(name: "updated_since", value: updatedSince))
        } else {
            queryItems.append(URLQueryItem(name: "ordering", value: "datetime"))
            if let createdSince = createdSince {
                queryItems.append(URLQueryItem(name: "created_since", value: createdSince))
            }
        }

        urlComponents?.queryItems = queryItems

        return APIClient.fixPlusEncoding(urlComponents)
    }
}
