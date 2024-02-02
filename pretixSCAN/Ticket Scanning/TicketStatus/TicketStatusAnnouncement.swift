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
//    var firstScan: String = "" not supported yet on iOS!!
    var lastScan: String = ""
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
            lastScan = Self.determineLastScan(redemptionResponse, isExitMode)
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
                // if we got here, it means the error was not managed so let's send us a signal
                EventLogger.log(event: "Ticked validation failed for unknown reason: \(String(describing: error))", category: .general, level: .error, type: .error)
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
        }
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
        }
    }
    
    static func determineLastScan(_ redemptionResponse: RedemptionResponse, _ isExitMode: Bool) -> String {
        switch redemptionResponse.status {
        case .redeemed:
            return ""
        case .incomplete:
            return ""
        case .error:
            if redemptionResponse.errorReason == .alreadyRedeemed, let lastCheckIn = redemptionResponse.lastCheckIn {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .medium
                return dateFormatter.string(from: lastCheckIn.date)
            }
            
            return ""
        }
    }
    
    static func determineAdditionalTexts(_ redemptionResponse: RedemptionResponse, _ isExitMode: Bool) -> [String] {
        if !isExitMode {
            return redemptionResponse.checkInTexts ?? []
        }
        return []
    }
}
