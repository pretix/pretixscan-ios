//
//  ApiResourcePath.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 27/10/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation

struct ApiResourcePath {
    static func eventDetail(organizer: String, event: String) -> String {
        return "organizers/\(organizer)/events/\(event)/"
    }

    static func eventSettings(organizer: String, event: String) -> String {
        return "organizers/\(organizer)/events/\(event)/settings/"
    }
}
