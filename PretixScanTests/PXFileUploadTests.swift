//
//  PXFileUploadTests.swift
//  PretixScanTests
//
//  Created by Konstantin Kostov on 01/03/2022.
//  Copyright © 2022 rami.io. All rights reserved.
//

import XCTest

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
}
