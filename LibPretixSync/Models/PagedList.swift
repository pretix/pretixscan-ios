//
//  PagedList.swift
//  PretixScan
//
//  Created by Daniel Jilg on 18.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

/// A list of elements returned from the API.
///
/// Includes Metadata such as the number of pages, and links to the
/// previous and next page. Can also optionally contain the servers
/// `X-Page-Generated` header.
public struct PagedList<T: Codable>: Codable {
    public let count: Int
    public let next: URL?
    public let previous: URL?
    public let results: [T]
    public var generatedAt: String?
}
