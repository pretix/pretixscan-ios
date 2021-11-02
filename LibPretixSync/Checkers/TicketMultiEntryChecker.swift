//
//  TicketMultiEntryChecker.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 29/10/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation

final class TicketMultiEntryChecker {
    private var checkInList: CheckInList
    weak var dataStore: DatalessDataStore?
    
    init(list: CheckInList, dataStore: DatalessDataStore) {
        self.checkInList = list
        self.dataStore = dataStore
    }
    
    func redeem(secret: String, event: Event) -> Result<Void, ValidationError> {
        if checkInList.allowMultipleEntries {
            return .success(())
        }
        
        guard let result = dataStore?.getQueuedCheckIns(secret, eventSlug: event.slug) else {
            fatalError("dataStore instance has been disposed")
        }
        
        switch result {
        case .success(let queuedCheckIns):
            if queuedCheckIns.isEmpty {
                // no known checkins for this ticket
                return .success(())
            }
            
            if !queuedCheckIns.contains(where: {$0.redemptionRequest.type != "exit"}) {
                // all queued checkins are for an exit
                return .success(())
            }
            
            if checkInList.allowEntryAfterExit, let lastCheckIn = queuedCheckIns.last, lastCheckIn.redemptionRequest.type == "exit" {
                // list allows entry after exit
                return .success(())
            }
            
            return .failure(.alreadyRedeemed)
        case .failure(let err):
            EventLogger.log(event: "Failed to get queued checkins during ticket validation: \(err.localizedDescription)", category: .database, level: .error, type: .error)
            return .failure(.unknownError)
        }
    }
    
    enum ValidationError: Error, Hashable, Equatable {
        case alreadyRedeemed
        case unknownError
    }
}
