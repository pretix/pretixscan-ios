//
//  URL+mimeType.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 01/03/2022.
//  Copyright © 2022 rami.io. All rights reserved.
//

import UniformTypeIdentifiers

extension URL {
    /// Return the mime type of the file at the specified path.
    public func mimeType() -> String? {
        if let mimeType = UTType(filenameExtension: self.pathExtension)?.preferredMIMEType {
            return mimeType
        }
        
        return nil
    }
}
