//
//  PXUploadedFileId.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 01/03/2022.
//  Copyright © 2022 rami.io. All rights reserved.
//

import Foundation

/// A file uploaded to the server
/// https://docs.pretix.eu/en/latest/api/fundamentals.html#file-upload
struct PXUploadedFile: Codable {
    let id: String
}
