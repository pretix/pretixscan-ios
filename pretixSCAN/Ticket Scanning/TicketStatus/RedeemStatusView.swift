//
//  TicketStatusView.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 14/11/2023.
//  Copyright © 2023 rami.io. All rights reserved.
//

import SwiftUI

struct RedeemStatusView: View {
    @ObservedObject var viewModel: RedeemTicketViewModel
    
    var body: some View {
        if viewModel.isLoading {
            VStack {
                ProgressView()
                    .scaleEffect(150)
                Spacer()
            }
        } else {
            RedeemedTicketView(announcement: viewModel.announcement, redeemUnpaid: {
                viewModel.redeemUnpaid()
            })
        }
    }
}
