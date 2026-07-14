//
//  APIClient+EventSettings.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 15/07/2026.
//  Copyright © 2026 rami.io. All rights reserved.
//

import Foundation

extension APIClient {
    /// Returns a task that retrieves the `EventSettings` from the event-level `/settings/` endpoint.
    func getEventSettingsTask(event: Event, completionHandler: @escaping (Result<EventSettings, Error>) -> Void) -> URLSessionDataTask? {
        do {
            let resource = ApiResourcePath.eventSettings(organizer: try getOrganizerSlug(), event: event.slug)
            return getTask(resource, completionHandler: completionHandler)
        } catch {
            completionHandler(.failure(error))
            return nil
        }
    }
}
