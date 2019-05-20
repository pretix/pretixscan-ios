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
    static var insertQuery: String { get }
}

extension Event: FMDBModel {
    public static var creationQuery = """
            CREATE TABLE IF NOT EXISTS "\(stringName)" (
                "slug"    TEXT NOT NULL UNIQUE,
                "date"    TEXT,
                "name"    TEXT,
                PRIMARY KEY("name")
            )
        """

    public static var destructionQuery = "DROP TABLE IF EXISTS \"\(Event.stringName)\""

    // TODO: Insert Query for Event
    public static var insertQuery = ""
}

extension OrderPosition: FMDBModel {
    public static var creationQuery = """
        CREATE TABLE IF NOT EXISTS "\(OrderPosition.stringName)" (
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

    public static var destructionQuery = "DROP TABLE IF EXISTS \"\(OrderPosition.stringName)\""

    public static var insertQuery = """
        REPLACE INTO "\(OrderPosition.stringName)"
        ("id", "order", "positionid", "item", "variation", "price", "attendee_name", "attendee_email", "secret", "pseudonymization_id")
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
    """
}

extension CheckIn: FMDBModel {
    public static var creationQuery = """
        CREATE TABLE IF NOT EXISTS "\(CheckIn.stringName)" (
            "list"    INTEGER,
            "order_position"    INTEGER,
            "date"    TEXT
        );
    """

    public static var destructionQuery = "DROP TABLE IF EXISTS \"\(CheckIn.stringName)\""

    public static var insertQuery = """
        REPLACE INTO "\(CheckIn.stringName)"("list","date","order_position") VALUES (?,?,?);
    """
}

extension ItemCategory: FMDBModel {
    public static var creationQuery = """
        CREATE TABLE IF NOT EXISTS "\(ItemCategory.stringName)" (
            "id"    INTEGER NOT NULL UNIQUE,
            "name"    TEXT,
            "internal_name"    TEXT,
            "description"    TEXT,
            "position"    INTEGER,
            "is_addon"    INTEGER,
            PRIMARY KEY("id")
        );
    """

    public static var destructionQuery = "DROP TABLE IF EXISTS \"\(ItemCategory.stringName)\""

    public static var insertQuery = """
        REPLACE INTO "\(ItemCategory.stringName)"
        ("id", "name", "internal_name", "description", "position", "is_addon")
        VALUES (?, ?, ?, ?, ?, ?);
    """
}

extension Item: FMDBModel {
    public static var creationQuery = """
    CREATE TABLE IF NOT EXISTS "\(Item.stringName)" (
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

    public static var destructionQuery = "DROP TABLE IF EXISTS \"\(Item.stringName)\""

    public static var insertQuery = """
        REPLACE INTO \"\(Item.stringName)\"(
            "id","name","internal_name","default_price",
            "category","active","description","position",
            "checkin_attention","json"
        ) VALUES (?,?,?,?,?,?,?,?,?,?);
    """
}

extension SubEvent: FMDBModel {
    public static var creationQuery = """
    CREATE TABLE IF NOT EXISTS "\(SubEvent.stringName)" (
        "id"    INTEGER NOT NULL UNIQUE,
        "name"    TEXT,
        "event"    TEXT NOT NULL,
        "json"    TEXT,
        PRIMARY KEY("id")
    );
    """

    public static var destructionQuery = "DROP TABLE IF EXISTS \"\(SubEvent.stringName)\""

    public static var insertQuery = """
        REPLACE INTO "\(SubEvent.stringName)"("id","name","event","json") VALUES (?,?,?,?);
    """
}

extension Order: FMDBModel {
    public static var creationQuery = """
    CREATE TABLE IF NOT EXISTS "\(Order.stringName)" (
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

    public static var destructionQuery = "DROP TABLE IF EXISTS \"\(Order.stringName)\""

    public static var insertQuery = """
        REPLACE INTO "\(Order.stringName)"
            ("code","status","secret","email","checkin_attention",
            "require_approval","json")
        VALUES (?,?,?,?,?,?,?);

    """
}
