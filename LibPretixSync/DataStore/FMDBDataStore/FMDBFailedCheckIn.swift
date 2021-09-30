//
//  FMDBFailedCheckIn.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 30/09/2021.
//  Copyright © 2021 rami.io. All rights reserved.
//

import Foundation
import FMDB

extension FailedCheckIn: FMDBModel {
    static var creationQuery = """
    CREATE TABLE IF NOT EXISTS "\(stringName)" (
        "event_slug"        TEXT NOT NULL,
        "list_identifier"   INTEGER NOT NULL,
        "error_reason"      TEXT NOT NULL,
        "raw_barcode"       TEXT NOT NULL,
        "date"              TEXT NOT NULL,
        "scan_type"         TEXT NOT NULL,
        "position"          INTEGER,
        "raw_item"          INTEGER,
        "raw_variation"     INTEGER,
        "raw_sub_event"     INTEGER
    );
    """
    
    static var insertQuery = """
    INSERT INTO "\(stringName)"
    (event_slug, list_identifier, error_reason, raw_barcode, date, scan_type, position, raw_item, raw_variation, raw_sub_event) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
    """
    
    static var retrieveOneQuery = """
    SELECT rowid, * FROM "\(stringName)" ORDER BY date ASC LIMIT 1;
    """
    
    static var deleteOneQuery = """
    DELETE FROM "\(stringName)" WHERE rowid=?;
    """
    
    static func store(_ records: [FailedCheckIn], in queue: FMDatabaseQueue) {
        queue.inDatabase { database in
            for record in records {
                let event_slug = record.eventSlug
                let list_identifier = record.checkInListIdentifier
                let error_reason = record.errorReason
                let raw_barcode = record.rawBarcode
                let date = record.dateTime
                let scan_type = record.scanType
                let position = record.position
                let raw_item = record.rawItem
                let raw_variation = record.rawVariation
                let raw_sub_event = record.rawSubEvent
                
                do {
                    try database.executeUpdate(Self.insertQuery, values: [event_slug, list_identifier, error_reason, raw_barcode, date as Any, scan_type, position as Any, raw_item as Any, raw_variation as Any, raw_sub_event as Any])
                } catch {
                    EventLogger.log(event: "\(error.localizedDescription)", category: .database, level: .error, type: .error)
                }
            }
        }
    }
    
    static func from(result: FMResultSet, in database: FMDatabase) -> FailedCheckIn? {
        guard let eventSlug = result.string(forColumn: "event_slug") else {
            logger.debug("Missing event_slug for \(humanReadableName).")
            return nil
        }
        
        guard let errorReason = result.string(forColumn: "error_reason") else {
            logger.debug("Missing error_reason for \(humanReadableName).")
            return nil
        }
        
        guard let rawBarcode = result.string(forColumn: "raw_barcode") else {
            logger.debug("Missing raw_barcode for \(humanReadableName).")
            return nil
        }
        
        guard let scanType = result.string(forColumn: "scan_type") else {
            logger.debug("Missing scan_type for \(humanReadableName).")
            return nil
        }
        
        let position = result.isNull(column: "position") ? nil : Int(result.int(forColumn: "position"))
        let rawItem = result.isNull(column: "raw_item") ? nil : Int(result.int(forColumn: "raw_item"))
        let rawVariation = result.isNull(column: "raw_variation") ? nil : Int(result.int(forColumn: "raw_variation"))
        let rawSubEvent = result.isNull(column: "raw_sub_event") ? nil : Int(result.int(forColumn: "raw_sub_event"))
        
        
        return FailedCheckIn(eventSlug: eventSlug, checkInListIdentifier: Identifier(result.int(forColumn: "list_identifier")), errorReason: errorReason, rawBarcode: rawBarcode, dateTime: result.date(forColumn: "date"), scanType: scanType, position: position, rawItem: rawItem, rawVariation: rawVariation, rawSubEvent: rawSubEvent)
    }
}
