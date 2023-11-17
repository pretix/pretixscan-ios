//
//  CheckInUnpaidButtonStyle.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 17/11/2023.
//  Copyright © 2023 rami.io. All rights reserved.
//

import SwiftUI

struct PrimaryGreenButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(backgroundColor)
            .foregroundStyle(foregroundStyle)
            .tint(tintColor)
            .font(.headline)
            .clipShape(Capsule())
    }
    
    var backgroundColor: Color {
        Color(uiColor: PXColor.primaryGreen)
    }
    
    var tintColor: Color {
        Color(uiColor: PXColor.primaryGreenText)
    }
    
    var foregroundStyle: Color {
        Color(uiColor: PXColor.primaryGreenText)
    }
}
