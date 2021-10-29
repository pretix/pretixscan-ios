//
//  SignedDataStore.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 28/10/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation

public protocol SignedDataStore: AnyObject {
    // MARK: - Event Keys
    
    /// Return the list of cached `EventValidKey` for the specified event.
    func getValidKeys(for event: Event) -> Result<[EventValidKey], Error>
    
    /// Return the list of cached `RevokedSecret` for the specified event.
    func getRevokedKeys(for event: Event) -> Result<[RevokedSecret], Error>
    
    
    // MARK: - Retrieving
    /// Retrieve an `Item` instance with the specified identifier, is such an Item exists
    func getItem(by identifier: Identifier, in event: Event) -> Item?
    
    /// Retrieve Questions that should be answered for the specified Item
    func getQuestions(for item: Item, in event: Event) -> Result<[Question], Error>
    
    /// Retrieve queued redemption requests for the specfied ticket
    func getQueuedCheckIns(_ secret: String, eventSlug: String) -> Result<[QueuedRedemptionRequest], Error>
}
