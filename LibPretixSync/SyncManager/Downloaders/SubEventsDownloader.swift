//
//  SubEventsDownloader.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 27/10/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation

class SubEventsDownloader: ConditionalDownloader<SubEvent> {
    let model = SubEvent.self
}
