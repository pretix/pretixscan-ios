//
//  RedeemedTicketView.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 15/11/2023.
//  Copyright © 2023 rami.io. All rights reserved.
//

import SwiftUI

struct RedeemedTicketView: View {
    let announcement: TicketStatusAnnouncement
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                VStack {
                    Text(announcement.icon)
                        .font(iconFontAwesome)
                    
                    if !announcement.status.isEmpty {
                        Text(announcement.status)
                            .font(.title)
                    }
                    
                    if !announcement.productType.isEmpty {
                        Text(announcement.productType)
                            .font(.subheadline)
                    }
                    
                    if !announcement.reason.isEmpty {
                        Text(announcement.reason)
                    }
                    
                    if !announcement.lastScan.isEmpty {
                        Text("Last scan: \(announcement.lastScan)")
                    }
                }
                
                if announcement.showAttention {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text("Attention, special ticket!")
                    }
                    .background(attentionBackground)
                }
                
                VStack(alignment:. leading) {
                    
                    HStack {
                        Text(announcement.attendeeName)
                            .bold()
                        Spacer()
                        Text(announcement.orderAndPosition)
                    }
                    
                    if !announcement.seat.isEmpty {
                        Text(announcement.seat)
                    }
                    
                    Text(announcement.additionalTexts.joined(separator: "\n"))
                }.background(detailsBackground)
                
                HStack {
                    Spacer()
                }
            }
            .padding(.vertical)
        }
        .background(announcement.background)
    }
    
    
    var iconFontAwesome: Font {
        let rawFont = UIFont(name: "FontAwesome5Free-Solid", size: 68)!
        return Font(rawFont)
    }
    
    var attentionBackground: Color {
        return Color(uiColor: UIColor(named: "blue")!)
    }
    
    var detailsBackground: Color {
        return Color(uiColor: UIColor(named: "grayBackground")!)
    }
}
