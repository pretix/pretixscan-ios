//
//  FMDBQueries.swift
//  pretixSCAN
//
//  Created by Daniel Jilg on 16.05.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

public protocol FMDBModel {
    static var tableName: String { get }
    static var creationQuery: String { get }
    static var destructionQuery: String { get }
}

extension Event: FMDBModel {
    public static var tableName = "events"

    public static var creationQuery = """
            CREATE TABLE IF NOT EXISTS "\(Event.tableName)" (
                "slug"    TEXT NOT NULL UNIQUE,
                "date"    TEXT,
                "name"    TEXT,
                PRIMARY KEY("name")
            )
        """

    public static var destructionQuery = "DROP TABLE IF EXISTS \"\(Event.tableName)\""
}

extension OrderPosition: FMDBModel {
    public static var tableName = "orderpositions"

    public static var creationQuery = """
        CREATE TABLE IF NOT EXISTS "\(OrderPosition.tableName)" (
            "id"    INTEGER NOT NULL UNIQUE,
            "order"    TEXT,
            "positionid"    INTEGER,
            "item"    INTEGER,
            "variation"    INTEGER,
            "price"    TEXT,
            "attendee_name"    TEXT,
            "attendee_email"    TEXT,
            "secret"    TEXT,
            "pseudonymization_id"    TEXT,
            PRIMARY KEY("id")
        );
    """

    public static var destructionQuery = "DROP TABLE IF EXISTS \"\(OrderPosition.tableName)\""
}

}
