//
//  RedeemTicketView.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 15/11/2023.
//  Copyright © 2023 rami.io. All rights reserved.
//

import SwiftUI

struct RedeemTicketView: View {
    let configuration: TicketStatusConfiguration
    @StateObject var viewModel: RedeemTicketViewModel
    
    init(configuration: TicketStatusConfiguration) {
        self.configuration = configuration
        self._viewModel = StateObject(wrappedValue: RedeemTicketViewModel(configuration: configuration))
    }
    
    var body: some View {
        RedeemStatusView(viewModel: viewModel)
            .task({
                await viewModel.redeem()
            })
            .sheet(isPresented: $viewModel.askingQuestions, content: {
                QuestionsView(configStore: viewModel.configStore!, questions: viewModel.questions, answers: viewModel.answerSlots, onCancelAnswering: {viewModel.cancelAnsweringCheckInQuestions()}, onAnswered: {viewModel.receivedAnswers($0)})
            })
    }
}
