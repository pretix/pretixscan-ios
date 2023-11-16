//
//  ConditionalViewModifiers.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 16/11/2023.
//  Copyright © 2023 rami.io. All rights reserved.
//

import SwiftUI

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content)
        -> some View
    {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    @ViewBuilder func `if`<Content: View>(
        _ condition: Bool, _ transform: (Self) -> Content, elseTransform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        } else {
            elseTransform(self)
        }
    }
}

