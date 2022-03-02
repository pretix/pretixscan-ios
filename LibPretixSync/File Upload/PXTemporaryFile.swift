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
    static let FilePrefix: String = "file://"
    
    var description: String {
        return self.contentURL.absoluteString
    }
    
    let contentURL: URL
    
    func delete() {
        do {
            try FileManager.default.removeItem(at: self.contentURL)
        } catch {
            logger.error("Error deleting a temporary file at '\(self.contentURL)': \(String(describing: error))")
        }
    }
}



extension PXTemporaryFile {
    init(extension ext: String) {
        self = PXTemporaryFile(contentURL: URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(ext))
    }
    
    
    init(path: String) {
        self = PXTemporaryFile(contentURL: URL(fileURLWithPath: path))
    }
}
