//
//  PXPackageLicense.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 18/05/2022.
//  Copyright © 2022 rami.io. All rights reserved.
//

import Foundation

struct PXPackageLicense: Equatable, Hashable, Codable {
    /// Name of the package or library
    let name: String
    
    /// External link to the package repository
    let url: String
    
    /// Friendly name of the license e.g. "MIT License"
    let license: String
}

let AppPackageLicenses: [PXPackageLicense] = [
    .init(name: "SwiftMessages", url: "https://github.com/SwiftKickMobile/SwiftMessages", license: "MIT License"),
    .init(name: "FMDB", url: "https://github.com/ccgus/fmdb", license: "MIT License"),
    .init(name: "PhoneNumberKit", url: "https://github.com/marmelroy/PhoneNumberKit", license: "MIT License"),
    .init(name: "Sentry", url: "https://github.com/getsentry/sentry-cocoa", license: "MIT License"),
    .init(name: "SwiftProtobuf", url: "https://github.com/apple/swift-protobuf.git", license: "Apache 2.0"),
    .init(name: "SwiftyJSON", url: "https://github.com/SwiftyJSON/SwiftyJSON.git", license: "MIT License"),
    .init(name: "jsonlogic", url: "https://github.com/advantagefse/json-logic-swift", license: "MIT License"),
]
