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
}
