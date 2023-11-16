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
    var attendeeName: String = ""
    var orderAndPosition: String = ""
    var seat: String = ""
    var additionalTexts: [String] = []
    
    static func empty() -> Self {
        TicketStatusAnnouncement(nil, nil, false, false)
    }
}


extension TicketStatusAnnouncement  {
    init(_ redemptionResponse: RedemptionResponse?, _ error: Error?, _ isExitMode: Bool, _ canCheckInUnpaid: Bool) {
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
        } else if let error = error {
            icon = Icon.error
            background = Color(uiColor: PXColor.error)
            status = Localization.TicketStatusViewController.InvalidTicket
            if let apiError = error as? APIError {
                switch apiError {
                case .notFound:
                    reason = Localization.Errors.TicketNotFound
                default:
                    reason = error.localized
                }
            }
        }
    }
    
    private static func determineOrderAndPosition(_ redemptionResponse: RedemptionResponse) -> String {
        let order = redemptionResponse.position?.orderCode ?? ""
        if let variationId = redemptionResponse.position?.positionid {
            return "\(order)-\(String(variationId))"
        }
        return order
    }
    
    private static func determineBackground(_ redemptionResponse: RedemptionResponse) -> Color {
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
    
    private static func determineIcon(_ redemptionResponse: RedemptionResponse, _ isExitMode: Bool) -> String {
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
    
    private static func determineStatus(_ redemptionResponse: RedemptionResponse, _ isExitMode: Bool) -> String {
        switch redemptionResponse.status {
        case .redeemed:
            if isExitMode {
                return Localization.TicketStatusViewController.ValidExit
            }
            return Localization.TicketStatusViewController.ValidTicket
        case .incomplete:
            return ""
        case .error:
            if redemptionResponse.errorReason == .alreadyRedeemed {
                return Localization.TicketStatusViewController.TicketAlreadyRedeemed
            }
            
            return Localization.TicketStatusViewController.InvalidTicket
        }
    }
    
    private static func determineLastScan(_ redemptionResponse: RedemptionResponse, _ isExitMode: Bool) -> String {
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
    
    private static func determineAdditionalTexts(_ redemptionResponse: RedemptionResponse, _ isExitMode: Bool) -> [String] {
        if !isExitMode {
            return redemptionResponse.checkInTexts ?? []
        }
        return []
    }
}
