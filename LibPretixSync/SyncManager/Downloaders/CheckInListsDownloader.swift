//
//  CheckInListsDownloader.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 27/10/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation

class CheckInListsDownloader: ConditionalDownloader<CheckInList> {
    let model = CheckInList.self
    var configStore: ConfigStore?

    override func handle(data: [CheckInList]) {
        guard let currentEvent = configStore?.event, let currentCheckInList = configStore?.checkInList else { return }
        for checkInList in data where checkInList == currentCheckInList {
            configStore?.set(event: currentEvent, checkInList: checkInList)
        }
    }
}
