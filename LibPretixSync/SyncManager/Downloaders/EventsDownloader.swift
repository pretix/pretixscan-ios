//
//  EventsDownloader.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 27/10/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation

class EventsDownloader: FullDownloader<Event> {
    let model = Event.self
    var configStore: ConfigStore?

    override func handle(data: [Event]) {
        guard let currentEvent = configStore?.event, let currentCheckInList = configStore?.checkInList else { return }
        for event in data where event == currentEvent {
            configStore?.set(event: event, checkInList: currentCheckInList)
        }
    }
}
