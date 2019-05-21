//
//  FMDBQueries.swift
//  pretixSCAN
//
//  Created by Daniel Jilg on 16.05.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation

public protocol FMDBModel: Model {
    static var creationQuery: String { get }
    static var destructionQuery: String { get }
    static var insertQuery: String { get }
}

public extension FMDBModel {
    static var destructionQuery: String { return "DROP TABLE IF EXISTS \"\(stringName)\"" }
}

extension OrderPosition: FMDBModel {
    public static var creationQuery = """
        CREATE TABLE IF NOT EXISTS "\(stringName)" (
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

    public static var insertQuery = """
        REPLACE INTO "\(stringName)"
        ("id", "order", "positionid", "item", "variation", "price", "attendee_name", "attendee_email", "secret", "pseudonymization_id")
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
    """
}

extension CheckIn: FMDBModel {
    public static var creationQuery = """
        CREATE TABLE IF NOT EXISTS "\(stringName)" (
            "list"    INTEGER,
            "order_position"    INTEGER,
            "date"    TEXT
        );
    """

    public static var insertQuery = """
        REPLACE INTO "\(stringName)"("list","date","order_position") VALUES (?,?,?);
    """
}

extension ItemCategory: FMDBModel {
    public static var creationQuery = """
        CREATE TABLE IF NOT EXISTS "\(stringName)" (
            "id"    INTEGER NOT NULL UNIQUE,
            "name"    TEXT,
            "internal_name"    TEXT,
            "description"    TEXT,
            "position"    INTEGER,
            "is_addon"    INTEGER,
            PRIMARY KEY("id")
        );
    """

    public static var insertQuery = """
        REPLACE INTO "\(stringName)"
        ("id", "name", "internal_name", "description", "position", "is_addon")
        VALUES (?, ?, ?, ?, ?, ?);
    """
}

extension Item: FMDBModel {
    public static var creationQuery = """
    CREATE TABLE IF NOT EXISTS "\(stringName)" (
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

    public static var insertQuery = """
        REPLACE INTO \"\(stringName)\"(
            "id","name","internal_name","default_price",
            "category","active","description","position",
            "checkin_attention","json"
        ) VALUES (?,?,?,?,?,?,?,?,?,?);
    """
}

extension SubEvent: FMDBModel {
    public static var creationQuery = """
    CREATE TABLE IF NOT EXISTS "\(stringName)" (
        "id"    INTEGER NOT NULL UNIQUE,
        "name"    TEXT,
        "event"    TEXT NOT NULL,
        "json"    TEXT,
        PRIMARY KEY("id")
    );
    """

    public static var insertQuery = """
        REPLACE INTO "\(stringName)"("id","name","event","json") VALUES (?,?,?,?);
    """
}

extension Order: FMDBModel {
    public static var creationQuery = """
    CREATE TABLE IF NOT EXISTS "\(stringName)" (
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

    public static var insertQuery = """
        REPLACE INTO "\(stringName)"
            ("code","status","secret","email","checkin_attention",
            "require_approval","json")
        VALUES (?,?,?,?,?,?,?);

    """
}

extension QueuedRedemptionRequest: FMDBModel {
    public static var creationQuery = """
        CREATE TABLE IF NOT EXISTS "\(stringName)" (
            "event"    TEXT NOT NULL,
            "check_in_list"    INTEGER NOT NULL,
            "secret"    TEXT NOT NULL,
            "questions_supported"    INTEGER,
            "datetime"    TEXT,
            "force"    INTEGER,
            "ignore_unpaid"    INTEGER,
            "nonce"    TEXT NOT NULL UNIQUE,
            PRIMARY KEY("nonce")
        );
    """

    public static var insertQuery = """
        REPLACE INTO "\(stringName)"
        ("event", "check_in_list", "secret", "questions_supported",
        "datetime", "force", "ignore_unpaid", "nonce")
        VALUES (?, ?, ?, ?, ?, ?, ?, ?);
    """
}
