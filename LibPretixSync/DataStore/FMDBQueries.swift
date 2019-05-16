//
//  FMDBQueries.swift
//  pretixSCAN
//
//  Created by Daniel Jilg on 16.05.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

public protocol FMDBModel {
    static var creationQuery: String { get }
    static var destructionQuery: String { get }
}

extension Event: FMDBModel {
    public static var creationQuery: String = """
            CREATE TABLE IF NOT EXISTS "events" (
                "slug"    TEXT NOT NULL UNIQUE,
                "date"    TEXT,
                "name"    TEXT,
                PRIMARY KEY("name")
            )
        """

    public static var destructionQuery = "DROP TABLE IF EXISTS \"events\""
}
