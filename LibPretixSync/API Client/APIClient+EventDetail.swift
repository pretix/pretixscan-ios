//
//  APIClient+EventDetail.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 27/10/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation

extension APIClient {
    func getEventDetailTask(_ eventSlug: String, completionHandler: @escaping (Result<Event, Error>) -> Void) -> URLSessionDataTask? {
        
        do {
            let resource = ApiResourcePath.eventDetail(organizer: try getOrganizerSlug(), event: eventSlug)
            
            return getTask(resource, completionHandler: completionHandler)
        } catch {
            completionHandler(.failure(error))
            return nil
        }
        
    }
}
