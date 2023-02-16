//
//  XCTests+loadFile.swift
//  XCTests+loadFile
//
//  Created by Konstantin Kostov on 10/09/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation
import XCTest

final private class OwnerClass {}

extension XCTestCase {
    func URLForResource(fileName: String, withExtension: String) -> URL {
        return Bundle(for: OwnerClass.self).url(forResource: fileName, withExtension: withExtension)!
    }
    
    func testFileContents(_ filename: String, _ ext: String = "json") -> Data {
        let url = URLForResource(fileName: filename, withExtension: ext)
        return try! Data.init(contentsOf: url)
    }
    
    func defaultsKey(_ key: String) -> String {
        return "eu.pretix.pretixscan.ios.\(key)"
    }
}
