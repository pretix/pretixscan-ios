//
//  URL+parentDirectory.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 05/12/2023.
//  Copyright © 2023 rami.io. All rights reserved.
//

import Foundation

extension URL {
    
    /// Return the parent directory of the resource, or nil if the resource is the root directory of its volume.
    func parentDirectory() throws -> URL? {
        return (try resourceValues(forKeys: [.parentDirectoryURLKey])).parentDirectory
    }
    
    /// Returns the protection level of a file resource.
    func fileProtection() throws -> URLFileProtection? {
        return (try resourceValues(forKeys: [.fileProtectionKey])).fileProtection
    }
    
    /// Sets the URL’s file protection property to `completeUntilFirstUserAuthentication`.
    func disableFileProtection() throws {
        let asURL = self as NSURL
        try asURL.setResourceValue(URLFileProtection.completeUntilFirstUserAuthentication, forKey: .fileProtectionKey)
    }
    
    /// Adapts the parent directory for a given file URL to allow access when the device is locked.
    func configureParentDirectoryProtection() throws {
        if let parentDirectory = try self.parentDirectory() {
            try parentDirectory.disableFileProtection()
            try self.disableFileProtection()
            
            if try self.fileProtection() != .completeUntilFirstUserAuthentication {
                EventLogger.log(event: "Database file protection failure: failed to configure", category: .database, level: .error, type: .error)
            }
        }
    }
}
