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
    static let FilePrefix: String = "pxtemporary://"
    
    var description: String {
        return self.contentURL.absoluteString
    }
    
    let contentURL: URL
    
    let name: String
    
    func delete() {
        do {
            try FileManager.default.removeItem(atPath: contentURL.relativePath)
        } catch {
            logger.error("Error deleting a temporary file at '\(self.contentURL)': \(String(describing: error))")
        }
    }
}



extension PXTemporaryFile {
    init(extension ext: String) {
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(ext)
        self = PXTemporaryFile(contentURL: url, name: url.lastPathComponent)
    }
    
    init(name: String) {
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(name)
        self = PXTemporaryFile(contentURL: url, name: url.lastPathComponent)
    }
}

extension PXTemporaryFile {
    
    /// Purges all temporary files
    static func cleanUpAll() {
        logger.debug("Puring all temporary files")
        let folder = NSTemporaryDirectory()
        let dirEnum = FileManager.default.enumerator(atPath: folder)
        while let file = dirEnum?.nextObject() as? String {
            let filePath = folder.appending("/\(file)")
            if FileManager.default.isDeletableFile(atPath: filePath) {
                do {
                    try FileManager.default.removeItem(atPath: filePath)
                } catch {
                    logger.error("🍅 Error deleting file at \(filePath): \(String(describing: error))")
                }
            }
        }
    }
    
    /// Purges temporary files at the provided prefixed file paths
    static func cleanUp(_ filePaths: [String]) {
        if filePaths.isEmpty {
            return
        }
        DispatchQueue.global(qos: .background).async {
            for filePath in filePaths {
                if Self.isTemporaryFilePath(filePath) {
                    logger.debug("🗑 Deleting file attachment at path '\(filePath)'.")
                    let temporaryFile = Self.removePathPrefix(filePath)
                    temporaryFile.delete()
                } else {
                    EventLogger.log(event: "File path '\(filePath)' is not a temporary file.", category: .configuration, level: .warning, type: .debug)
                }
            }
        }
    }
    
    /// Purges temporary files at the provided relative URLs
    static func cleanUp(_ fileUrls: [URL]) {
        if fileUrls.isEmpty {
            return
        }
        DispatchQueue.global(qos: .background).async {
            for fileUrl in fileUrls {
                logger.debug("🗑 Deleting file attachment at url \(fileUrl)")
                let temporaryFile = PXTemporaryFile(name: fileUrl.lastPathComponent)
                temporaryFile.delete()
            }
        }
    }
    
    /// Removes the `FilePrefix` prefix from a relative file path so it can be used to construct a `URL`
    static func removePathPrefix(_ path: String) -> PXTemporaryFile {
        let name = path.replacingOccurrences(of: PXTemporaryFile.FilePrefix, with: "", options: .caseInsensitive, range: nil)
        return PXTemporaryFile(name: name)
    }
    
    /// Checks if the string starts with the `FilePrefix` prefix indicating that it's a local file path
    static func isTemporaryFilePath(_ path: String) -> Bool {
        path.starts(with: PXTemporaryFile.FilePrefix)
    }
    
    /// Prefixes a relative URL filepath with `FilePrefix` so it can be detected in plain string answer values
    static func addPathPrefix(_ path: URL) -> String {
        "\(Self.FilePrefix)\(path.lastPathComponent)"
    }
}
