//
//  PXFileUploadTests.swift
//  PretixScanTests
//
//  Created by Konstantin Kostov on 01/03/2022.
//  Copyright © 2022 rami.io. All rights reserved.
//

import XCTest
@testable import pretixSCAN


class PXFileUploadTests: XCTestCase {
    func testDetectMimeTypeJPEG() {
        let fileUrl = URLForResource(fileName: "imageJPEG", withExtension: "jpg")
        XCTAssertEqual(fileUrl.mimeType(), "image/jpeg")
    }
    
    func testDetectMimeTypePNG() {
        let fileUrl = URLForResource(fileName: "imagePNG", withExtension: "png")
        XCTAssertEqual(fileUrl.mimeType(), "image/png")
    }
    
    func testGettingFileNameFromURL() {
        let fileUrl = URLForResource(fileName: "imagePNG", withExtension: "png")
        XCTAssertEqual(fileUrl.lastPathComponent, "imagePNG.png")
    }
    
    func testCreateTemporaryFile() {
        let image = UIImage(data: testFileContents("imageJPEG", "jpg"))!
        let temporaryFile = PXTemporaryFile(extension: "jpeg")
        if let data = image.jpegData(compressionQuality: 1.0) {
            do {
                try data.write(to: temporaryFile.contentURL)
                
                XCTAssertTrue(FileManager.default.fileExists(atPath: temporaryFile.contentURL.relativePath))
                
            } catch {
                XCTFail("Error writing thumbnail to temporary file at \(temporaryFile): \(String(describing: error))")
            }
        } else {
            XCTFail("Failed to export image")
        }
    }
    
    func testTemporaryFilePathAsString() {
        let image = UIImage(data: testFileContents("imageJPEG", "jpg"))!
        let temporaryFile = PXTemporaryFile(extension: "jpeg")
        if let data = image.jpegData(compressionQuality: 1.0) {
            do {
                try data.write(to: temporaryFile.contentURL)
                
                let stringPath = PXTemporaryFile.addPathPrefix(temporaryFile.contentURL)
                
                XCTAssertTrue(PXTemporaryFile.isTemporaryFilePath(stringPath))
                
                let filePath = PXTemporaryFile.removePathPrefix(stringPath).contentURL
                XCTAssertTrue(FileManager.default.fileExists(atPath: filePath.relativePath))
                
            } catch {
                XCTFail("Error writing thumbnail to temporary file at \(temporaryFile): \(String(describing: error))")
            }
        } else {
            XCTFail("Failed to export image")
        }
    }
    
    func testCleanupAll() {
        let image = UIImage(data: testFileContents("imageJPEG", "jpg"))!
        let temporaryFile = PXTemporaryFile(extension: "jpeg")
        if let data = image.jpegData(compressionQuality: 1.0) {
            do {
                try data.write(to: temporaryFile.contentURL)
                XCTAssertTrue(FileManager.default.fileExists(atPath: temporaryFile.contentURL.relativePath))
                
                PXTemporaryFile.cleanUpAll()
                
                XCTAssertFalse(FileManager.default.fileExists(atPath: temporaryFile.contentURL.relativePath))
                
            } catch {
                XCTFail("Error writing thumbnail to temporary file at \(temporaryFile): \(String(describing: error))")
            }
        } else {
            XCTFail("Failed to export image")
        }
    }
    
}
