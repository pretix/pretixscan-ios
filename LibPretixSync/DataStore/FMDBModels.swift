//
//  FMDBQueries.swift
//  pretixSCAN
//
//  Created by Daniel Jilg on 16.05.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import Foundation
import FMDB

// MARK: - Protocol
public protocol FMDBModel: Model {
    static var creationQuery: String { get }
    static var destructionQuery: String { get }
    static var insertQuery: String { get }
}

public extension FMDBModel {
    static var destructionQuery: String { return "DROP TABLE IF EXISTS \"\(stringName)\"" }
}

// MARK: - New Models
/// Represents when a certain model has been synced last, if at all
struct SyncTimeStamp: FMDBModel {
    public static let humanReadableName = "Sync Timestamp"
    public static let stringName = "sync_timestamps"

    public let model: String
    public let lastSyncedAt: String

    public static var creationQuery = """
        CREATE TABLE IF NOT EXISTS "\(stringName)" (
            "model"    TEXT NOT NULL UNIQUE,
            "last_synced_at"    TEXT,
            PRIMARY KEY("model")
        );
    """

    public static var insertQuery = """
        REPLACE INTO "\(stringName)"
        ("model", "last_synced_at")
        VALUES (?, ?);
    """

    public static var getSingleModelQuery = """
        SELECT * FROM \(stringName) WHERE model=?;
    """
}

// MARK: - Extensions of existing Models
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

    public static let searchQuery = """
        SELECT * FROM "\(OrderPosition.stringName)"
        LEFT JOIN "\(Order.stringName)"
        ON "\(OrderPosition.stringName)"."order" = "\(Order.stringName)"."code"
        LEFT JOIN "\(Item.stringName)"
        ON "\(OrderPosition.stringName)"."item" = "\(Item.stringName)"."id"
        WHERE "attendee_name" LIKE ?
        OR "attendee_email" LIKE ?
        OR "email" LIKE ?
        OR "code" LIKE ?;
    """

    public static func from(result: FMResultSet) -> OrderPosition? {
        let identifier = Int(result.int(forColumn: "id"))
        guard let order = result.string(forColumn: "order") else { return nil }
        let positionid = Int(result.int(forColumn: "positionid"))
        let item = Int(result.int(forColumn: "item"))
        let variation = Int(result.int(forColumn: "variation"))
        guard let price = result.string(forColumn: "price") else { return nil }
        let attendee_name = result.string(forColumn: "attendee_name")
        let attendee_email = result.string(forColumn: "attendee_email")
        guard let secret = result.string(forColumn: "secret") else { return nil }
        guard let pseudonymization_id = result.string(forColumn: "pseudonymization_id") else { return nil }

        let orderPosition = OrderPosition(
            identifier: identifier, order: order, positionid: positionid, item: item,
            variation: variation, price: price, attendeeName: attendee_name,
            attendeeEmail: attendee_email, secret: secret,
            pseudonymizationId: pseudonymization_id, checkins: [])
        return orderPosition
    }
}

extension CheckIn: FMDBModel {
    public static var creationQuery = """
        CREATE TABLE IF NOT EXISTS "\(stringName)" (
            "list"    INTEGER NOT NULL,
            "order_position"    INTEGER  NOT NULL,
            "date"    TEXT  NOT NULL,
            UNIQUE("list", "order_position", "date") ON CONFLICT REPLACE
        );
    """

    public static var insertQuery = """
        REPLACE INTO "\(stringName)"("list","order_position","date") VALUES (?,?,?);
    """

    public static let retrieveByOrderPositionQuery = """
        SELECT * FROM "\(stringName)" WHERE order_position=?;
    """

    public static func from(result: FMResultSet, in database: FMDatabase) -> CheckIn? {
        guard let date = database.dateFromString(result.string(forColumn: "date")) else {
            print("Date Parsing error in Checkin.from")
            return nil
        }
        let list = Identifier(result.int(forColumn: "list"))
        return CheckIn(listID: list, date: date)
    }
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

    public static var numberOfRequestsQuery = """
        SELECT COUNT(*) FROM "\(stringName)";
    """

    public static var retrieveOneRequestQuery = """
        SELECT * FROM "\(stringName)" LIMIT 1;
    """

    public static var deleteOneRequestQuery = """
        DELETE FROM "\(stringName)" WHERE nonce=?;
    """

    public static func from(result: FMResultSet, in database: FMDatabase) -> QueuedRedemptionRequest? {
        guard let event = result.string(forColumn: "event") else { return nil }
        let check_in_list = result.int(forColumn: "check_in_list")
        guard let secret = result.string(forColumn: "secret") else { return nil }
        let questions_supported = result.bool(forColumn: "questions_supported")
        let datetime = database.dateFromString(result.string(forColumn: "datetime"))

        let force = result.bool(forColumn: "force")
        let ignore_unpaid = result.bool(forColumn: "ignore_unpaid")
        guard let nonce = result.string(forColumn: "nonce") else { return nil }

        let redemptionRequest = RedemptionRequest(questionsSupported: questions_supported,
            date: datetime, force: force, ignoreUnpaid: ignore_unpaid, nonce: nonce)
        let queuedRedemptionRequest = QueuedRedemptionRequest(redemptionRequest: redemptionRequest,
            eventSlug: event, checkInListIdentifier: Int(check_in_list), secret: secret)

        return queuedRedemptionRequest
    }
}
