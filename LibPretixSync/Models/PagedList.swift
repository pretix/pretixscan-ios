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
    /// The amount of entities on this list (not just on this particular page)
    public let count: Int

    /// The URL of the next page in the list, if this is not the last page
    public var next: URL?

    /// The URL of the previous page in the list, if this is not the first page
    public let previous: URL?

    /// The current page slice of entities
    public let results: [T]

    /// An optional string representing the time when this page was generated.
    ///
    /// Should be equal to the `X-Page-Generated` header. Hang on to this value to use it for incremental syncing.
    public var generatedAt: String?

    /// An optional string representing the time when this page was last modified.
    ///
    /// Should be equal to the `Last-Modified` header. Hang on to this value to use it for incremental syncing.
    public var lastModified: String?
}
