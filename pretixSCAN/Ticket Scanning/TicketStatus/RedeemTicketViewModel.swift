//
//  TicketStatusViewModel.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 14/11/2023.
//  Copyright © 2023 rami.io. All rights reserved.
//

import Foundation
import UIKit

final class RedeemTicketViewModel: ObservableObject {
    private let configuration: TicketStatusConfiguration
    private weak var configStore: ConfigStore? = nil
    
    /// Gets the current scanning mode of the app - entry or exit
    private var scanMode: String {
        configStore!.scanMode
    }
    
    private var isExitMode: Bool {
        scanMode == "exit"
    }
    
    init(configuration: TicketStatusConfiguration) {
        self.configuration = configuration
        // get a reference to the application's current config store
        configStore = (UIApplication.shared.delegate as? AppDelegate)?.configStore
    }
    
    @MainActor
    private func announceResult(_ redemptionResponse: RedemptionResponse?, _ error: Error?) {
        
        // visual announcement
        announcement = TicketStatusAnnouncement(redemptionResponse, error, isExitMode, configStore!.checkInList!.includePending)
        
        // haptic and sound announcements
        if !configuration.ignoreUnpaid {
            configStore!.feedbackGenerator.announce(redemptionResponse: redemptionResponse, error, isExitMode)
        }
        
        self.isLoading = false
        
        //TODO: start auto-dismiss
    }
    
    
    
    @Published var isLoading: Bool = true
    @Published var announcement: TicketStatusAnnouncement = .empty()
    
    func redeem() async {
        do {
            let redemptionResponse = try await configStore!.ticketValidator!.redeem(configuration: configuration, as: scanMode)
            await announceResult(redemptionResponse, nil)
        } catch {
            await announceResult(nil, error)
        }
    }
}
