//
//  TicketStatusAnnouncement.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 15/11/2023.
//  Copyright © 2023 rami.io. All rights reserved.
//

import Foundation
import SwiftUI

/// Representation of the result of a redeem operation suitable for the status popup
struct TicketStatusAnnouncement: Hashable, Equatable {
    var icon: String = Icon.okay
    var background: Color = Color(uiColor: PXColor.grayBackground)
    
    var status: String = ""
    var productType: String = ""
    var reason: String = ""
    var singleEntry: String = ""
    var firstEntry: String = ""
    var lastEntry: String = ""
    var showAttention: Bool = false
    var showCheckInUnpaid: Bool = false
    var attendeeName: String = "-"
    var orderAndPosition: String = ""
    var seat: String = ""
    var additionalTexts: [String] = []
    var questions: [TicketKeyValuePair] = []
    var showOfflineIndicator: Bool = false
    
    
    
    static func empty() -> Self {
        TicketStatusAnnouncement(nil, nil, false, false, isOffline: false)
    }
    
    static func success() -> Self {
        TicketStatusAnnouncement(.redeemed, nil, false, false, isOffline: false)
    }
    
    static func product() -> Self {
        TicketStatusAnnouncement(.product, nil, false, false, isOffline: false)
    }
}


extension TicketStatusAnnouncement  {
    init(_ redemptionResponse: RedemptionResponse?, _ error: Error?, _ isExitMode: Bool, _ canCheckInUnpaid: Bool, isOffline: Bool) {
        showOfflineIndicator = isOffline
        
        if let redemptionResponse = redemptionResponse {
            background = Self.determineBackground(redemptionResponse)
            icon = Self.determineIcon(redemptionResponse, isExitMode)
            
            // set status
            status = Self.determineStatus(redemptionResponse, isExitMode)
            productType = redemptionResponse.calculatedProductLabel
            orderAndPosition = Self.determineOrderAndPosition(redemptionResponse)
            reason = redemptionResponse.localizedErrorReason

            
            if Self.showFirstEntry(isExitMode),
               let firstDate = redemptionResponse.firstEntryDate {
                self.firstEntry = Self.formatEntryDate(firstDate)
            } else {
                self.firstEntry = ""
            }
            
            if Self.showLastEntry(redemptionResponse, isExitMode),
               let _ = redemptionResponse.lastEntryDate {
                lastEntry = Self.determineLastEntry(redemptionResponse)
            } else {
                self.lastEntry = ""
            }
            
            if firstEntry == lastEntry && !firstEntry.isEmpty {
                singleEntry = firstEntry
                firstEntry = ""
                lastEntry = ""
            }
            
            showAttention = redemptionResponse.isRequireAttention
            showCheckInUnpaid = redemptionResponse.errorReason == .unpaid && canCheckInUnpaid

            // ticket details
            attendeeName = redemptionResponse.position?.attendeeName ?? ""
            seat = redemptionResponse.position?.seat?.name ?? ""
            additionalTexts = Self.determineAdditionalTexts(redemptionResponse, isExitMode)
            questions = redemptionResponse.visibleAnswers
        } else if let error = error {
            icon = Icon.error
            background = Color(uiColor: PXColor.error)
            status = Localization.TicketStatus.InvalidTicket
            if let apiError = error as? APIError {
                switch apiError {
                case .notFound:
                    reason = Localization.Errors.TicketNotFound
                default:
                    reason = error.localized
                }
            } else {
                reason = error.localizedDescription
            }
        }
    }
    
    static func determineOrderAndPosition(_ redemptionResponse: RedemptionResponse) -> String {
        let order = redemptionResponse.position?.orderCode ?? ""
        if let variationId = redemptionResponse.position?.positionid {
            return "\(order)-\(String(variationId))"
        }
        return order
    }
    
    static func determineBackground(_ redemptionResponse: RedemptionResponse) -> Color {
        switch redemptionResponse.status {
        case .redeemed:
            return Color(uiColor: PXColor.okay)
        case .incomplete:
            return Color(uiColor: PXColor.warning)
        case .error:
            if redemptionResponse.errorReason == .alreadyRedeemed {
                return Color(uiColor: PXColor.warning)
            }

            return Color(uiColor: PXColor.error)
        case .unknown:
            return Color(uiColor: PXColor.error)
        }
    }
    
    static func determineIcon(_ redemptionResponse: RedemptionResponse, _ isExitMode: Bool) -> String {
        switch redemptionResponse.status {
        case .redeemed:
            if isExitMode {
                return Icon.exit
            }
            return Icon.okay
        case .incomplete:
            return ""
        case .error:
            if redemptionResponse.errorReason == .alreadyRedeemed {
                return Icon.warning
            }

            return Icon.error
        case .unknown:
            return Icon.error
        }
    }
    
    static func showLastEntry(_ redemptionResponse: RedemptionResponse, _ isExitMode: Bool) -> Bool {
        switch redemptionResponse.status {
        case .redeemed:
            return false
        case .incomplete, .error, .unknown:
            if isExitMode {
               return false
            }
            return true
        }
    }
    
    static func showFirstEntry(_ isExitMode: Bool) -> Bool {
        if isExitMode {
            return false
        }
        return true
    }
    
    static func determineStatus(_ redemptionResponse: RedemptionResponse, _ isExitMode: Bool) -> String {
        switch redemptionResponse.status {
        case .redeemed:
            if isExitMode {
                return Localization.TicketStatus.ValidExit
            }
            return Localization.TicketStatus.ValidTicket
        case .incomplete:
            return ""
        case .error:
            if redemptionResponse.errorReason == .alreadyRedeemed {
                return Localization.TicketStatus.TicketAlreadyRedeemed
            }

            return Localization.TicketStatus.InvalidTicket
        case .unknown:
            return Localization.TicketStatus.InvalidTicket
        }
    }

    static func determineFirstEntry(_ redemptionResponse: RedemptionResponse) -> String {
        guard let firstEntryDate = redemptionResponse.firstEntryDate else {
            return ""
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        return dateFormatter.string(from: firstEntryDate)
    }

    static func determineLastEntry(_ redemptionResponse: RedemptionResponse) -> String {
        guard let lastEntryDate = redemptionResponse.lastEntryDate else {
            return ""
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        return dateFormatter.string(from: lastEntryDate)
    }

    static func formatEntryDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        return dateFormatter.string(from: date)
    }

    static func determineAdditionalTexts(_ redemptionResponse: RedemptionResponse, _ isExitMode: Bool) -> [String] {
        if !isExitMode {
            return redemptionResponse.checkInTexts ?? []
        }
        return []
    }
}
