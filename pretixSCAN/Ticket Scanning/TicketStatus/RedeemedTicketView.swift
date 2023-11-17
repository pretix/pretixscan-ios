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
    var redeemUnpaid: () -> Void
    
    var body: some View {
        ScrollView(.vertical) {
            ZStack {
                announcement.background
                    .ignoresSafeArea(edges: .all)
                
                if announcement.showOfflineIndicator {
                    VStack {
                        HStack {
                            Image(systemName: "wifi.slash")
                                .imageScale(.large)
                                .padding()
                                .padding(.top)
                            
                            Spacer()
                        }
                        .foregroundStyle(.white)
                        Spacer()
                    }
                }
                
                VStack(spacing: 0) {
                    VStack {
                        VStack {
                            Text(announcement.icon)
                                .font(iconFontAwesome)
                                .padding()
                            
                            if !announcement.status.isEmpty {
                                Text(announcement.status)
                                    .font(.title2).bold()
                            }
                            
                            if !announcement.productType.isEmpty {
                                Text(announcement.productType)
                                    .font(.title3)
                            }
                            
                            if !announcement.reason.isEmpty {
                                Text(announcement.reason)
                            }
                            
                            if !announcement.lastScan.isEmpty {
                                Text("Last scan: \(announcement.lastScan)")
                            }
                        }
                        .foregroundStyle(.white)
                        
                        
                        if announcement.showCheckInUnpaid {
                            Button(action: {
                                self.redeemUnpaid()
                            }, label: {
                                Text(Localization.TickerStatus.UnpaidContinueButtonTitle)
                            })
                            .buttonStyle(PrimaryGreenButtonStyle())
                        }
                    }
                    .padding(.bottom)
                    
                    VStack(spacing: 0) {
                        if announcement.showAttention {
                            VStack {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .imageScale(.large)
                                    Text("Attention, special ticket!")
                                        .bold()
                                    Spacer()
                                }
                            }
                            .padding()
                            .background(attentionBackground)
                            .foregroundStyle(.white)
                        }
                        
                        VStack(alignment:. leading) {
                            HStack {
                                Text(announcement.attendeeName)
                                    .font(.title3)
                                    .bold()
                                Spacer()
                                Text(announcement.orderAndPosition)
                                    .font(.title3)
                            }
                            
                            if !announcement.seat.isEmpty {
                                Text(announcement.seat)
                                    .font(.callout)
                            }
                            
                            VStack(alignment: .leading) {
                                // questions and answers
                                ForEach(announcement.questions, id: \.self) {q in
                                    HStack {
                                        Text(q.key)
                                            .bold() + Text(": ") + Text(q.value)
                                    }
                                }
                            }.padding(.top)
                            
                            // additional texts
                            Text(announcement.additionalTexts.joined(separator: "\n"))
                                .padding(.top)
                            
                            Spacer()
                        }
                        .padding([.top, .leading, .trailing])
                        .fixedSize(horizontal: false, vertical: true)
                        .background(detailsBackground)
                        
                    }
                    
                    HStack {
                        Spacer()
                    }
                }
                
                
                
            }
        }
        .background(detailsBackground)
    }
    
    
    var iconFontAwesome: Font {
        let rawFont = UIFont(name: "FontAwesome5Free-Solid", size: 64)!
        return Font(rawFont)
    }
    
    var attentionBackground: Color {
        return Color(uiColor: UIColor(named: "blue")!)
    }
    
    var detailsBackground: Color {
        return Color(uiColor: UIColor(named: "grayBackground")!)
    }
}

#Preview {
    RedeemedTicketView(announcement: TicketStatusAnnouncement(icon: Icon.okay, background: TicketStatusAnnouncement.determineBackground(.redeemed), status:TicketStatusAnnouncement.determineStatus(.redeemed, false), productType: "Product", reason: "Reason explained", lastScan: "17/11/2023 17:20", showAttention: true, showCheckInUnpaid: true, attendeeName: "Attendee Name", orderAndPosition: "AAAAB-1", seat: "Seat B by the window", additionalTexts: ["Comment on product or variation or label", "Lorem ipsum, or lipsum as it is sometimes known, is dummy text used in laying out print, graphic or web designs. The passage is attributed to an unknown typesetter in the 15th century who is thought to have scrambled parts of Cicero's De Finibus Bonorum et Malorum for use in a type specimen book. It usually begins with:", "Lorem ipsum, or lipsum as it is sometimes known, is dummy text used in laying out print, graphic or web designs. The passage is attributed to an unknown typesetter in the 15th century who is thought to have scrambled parts of Cicero's De Finibus Bonorum et Malorum for use in a type specimen book. It usually begins with:", "Lorem ipsum, or lipsum as it is sometimes known, is dummy text used in laying out print, graphic or web designs. The passage is attributed to an unknown typesetter in the 15th century who is thought to have scrambled parts of Cicero's De Finibus Bonorum et Malorum for use in a type specimen book. It usually begins with:"], questions: [.init(key: "Question", value: "answer"), .init(key: "question 2", value: "answer 2")], showOfflineIndicator: true), redeemUnpaid: {})
}
