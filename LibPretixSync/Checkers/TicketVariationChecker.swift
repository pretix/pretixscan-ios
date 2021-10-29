//
//  TicketVariationValidator.swift
//  PretixScanTests
//
//  Created by Konstantin Kostov on 28/10/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation

final class TicketVariationChecker {
    private var checkInList: CheckInList
    weak var dataStore: SignedDataStore?
    
    init(list: CheckInList, dataStore: SignedDataStore) {
        self.checkInList = list
        self.dataStore = dataStore
    }
    
    func redeem(ticket: SignedTicketData, item: Item) -> ItemVariation? {
        if ticket.variation > 0 {
            return item.variations.first(where: {$0.identifier == ticket.variation})
        }
        return nil
    }
}
