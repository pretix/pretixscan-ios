//
//  QeuedRedemptionRequest.swift
//  PretixScan
//
//  Created by Daniel Jilg on 01.05.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

/// Encapsulates a Redemption Request that should be queued until it has been uploaded to the server.
///
/// - See also `RedemptionRequest`
public struct QueuedRedemptionRequest: Model {
    public static var humanReadableName = "Queued Redemption Request"
    public static var stringName = "queued_redemption_requests"
    
    /// The redemption requet to upload to the server
    public var redemptionRequest: RedemptionRequest
    
    /// The slug of the event this request belongs to
    public let eventSlug: String
    
    /// The identifier of the check-in-olist this request belongs to
    public let checkInListIdentifier: Identifier
    
    /// The order position secret, identifying the attendee to checki in
    public let secret: String
}

extension QueuedRedemptionRequest: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(redemptionRequest)
        hasher.combine(eventSlug)
        hasher.combine(checkInListIdentifier)
        hasher.combine(secret)
    }
}


extension QueuedRedemptionRequest {
    func deleteAttachmentFiles() {
        let files = redemptionRequest.answers?.filter({$0.value.starts(with: PXTemporaryFile.FilePrefix)}) ?? [:]
        if !files.isEmpty {
            logger.debug("Deleting \(files.count) local files attachments...")
            DispatchQueue.global(qos: .background).async {
                for fileItem in files {
                    let filePath = fileItem.value.replacingOccurrences(of: PXTemporaryFile.FilePrefix, with: "", options: .caseInsensitive, range: nil)
                    let temporaryFile = PXTemporaryFile(path: filePath)
                    temporaryFile.delete()
                }
            }
        }
    }
}
