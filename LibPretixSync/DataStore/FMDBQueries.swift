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
    static var insertQuery: String { get }
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

    // TODO: Insert Query for Event
    public static var insertQuery = ""
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

    // TODO: Insert Query for OrderPosition
    public static var insertQuery = ""
}

extension CheckIn: FMDBModel {
    public static var tableName = "checkins"

    public static var creationQuery = """
        CREATE TABLE IF NOT EXISTS "\(CheckIn.tableName)" (
            "list"    INTEGER,
            "date"    TEXT
        );
    """

    public static var destructionQuery = "DROP TABLE IF EXISTS \"\(CheckIn.tableName)\""

    // TODO: Insert Query for CheckIn
    public static var insertQuery = ""
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

    public static var insertQuery = """
        INSERT INTO "main"."categories"
        ("id", "name", "internal_name", "description", "position", "is_addon")
        VALUES (?, ?, ?, ?, ?, ?);
    """
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
        "checkin_attention"    INTEGER,
        "json"    INTEGER,
        PRIMARY KEY("id")
    );
    """

    public static var destructionQuery = "DROP TABLE IF EXISTS \"\(Item.tableName)\""

    public static var insertQuery = """
        INSERT INTO \"\(Item.tableName)\"(
            "id","name","internal_name","default_price",
            "category","active","description","position",
            "checkin_attention","json"
        ) VALUES (?,?,?,?,?,?,?,?,?,?);
    """
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

    // TODO: Insert Query for Sub Event
    public static var insertQuery = ""
}

extension Order: FMDBModel {
    public static var tableName = "orders"

    public static var creationQuery = """
    CREATE TABLE IF NOT EXISTS "\(Order.tableName)" (
        "code"    TEXT NOT NULL UNIQUE,
        "status"    TEXT,
        "secret"    TEXT,
        "email"    TEXT,
        "checkin_attention"    INTEGER,
        "require_approval"    INTEGER,
        "json"    TEXT,
        PRIMARY KEY("code")
    );
    """

    public static var destructionQuery = "DROP TABLE IF EXISTS \"\(Order.tableName)\""

    // TODO: Insert Query for Order
    public static var insertQuery = ""
}

// TODO: SQL for Quotas
