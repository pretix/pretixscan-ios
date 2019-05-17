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

extension CheckIn: FMDBModel {
    public static var tableName = "checkins"

    public static var creationQuery = """
        CREATE TABLE "checkins" (
            "list"    INTEGER,
            "date"    TEXT
        );
    """

    public static var destructionQuery = "DROP TABLE IF EXISTS \"\(CheckIn.tableName)\""
}

extension ItemCategory: FMDBModel {
    public static var tableName = "categories"

    public static var creationQuery = """
        CREATE TABLE IF NOT EXISTS "\(ItemCategory.tableName)" (
            "id"    INTEGER NOT NULL UNIQUE,
            "name"    TEXT,
            "internal_name"    TEXT,
            "description"    TEXT,
            "position"    INTEGER,
            "is_addon"    INTEGER,
            PRIMARY KEY("id")
        );
    """

    public static var destructionQuery = "DROP TABLE IF EXISTS \"\(ItemCategory.tableName)\""
}

extension Item: FMDBModel {
    public static var tableName = "items"

    public static var creationQuery = """
    CREATE TABLE IF NOT EXISTS "\(Item.tableName)" (
        "id"    INTEGER NOT NULL UNIQUE,
        "name"    TEXT,
        "internal_name"    TEXT,
        "default_price"    TEXT,
        "category"    INTEGER,
        "active"    INTEGER,
        "description"    TEXT,
        "position"    INTEGER,
        "checkInAttention"    INTEGER,
        "json"    INTEGER,
        PRIMARY KEY("id")
    );
    """

    public static var destructionQuery = "DROP TABLE IF EXISTS \"\(Item.tableName)\""
}

extension SubEvent: FMDBModel {
    public static var tableName = "subevents"

    public static var creationQuery = """
    CREATE TABLE IF NOT EXISTS "\(SubEvent.tableName)" (
        "id"    INTEGER NOT NULL UNIQUE,
        "name"    TEXT,
        "event"    TEXT NOT NULL,
        "json"    TEXT,
        PRIMARY KEY("id")
    );
    """

    public static var destructionQuery = "DROP TABLE IF EXISTS \"\(SubEvent.tableName)\""
}

// TODO: SQL for Quotas
// TODO: SQL for Orders
