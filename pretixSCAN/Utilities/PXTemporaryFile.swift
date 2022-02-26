//
//  PXTemporaryFile.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 26/02/2022.
//  Copyright © 2022 rami.io. All rights reserved.
//

import Foundation

/// A reference to a temporary file
struct PXTemporaryFile: CustomStringConvertible {
    var description: String {
        return self.contentURL.absoluteString
    }
    
    let contentURL: URL
}



extension PXTemporaryFile {
    init(extension ext: String) {
        self = PXTemporaryFile(contentURL: URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(ext))
    }
}
