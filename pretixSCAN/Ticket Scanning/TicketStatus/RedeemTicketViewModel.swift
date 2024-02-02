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
    private let secret: String
    private let forcedRedeem: Bool
    private var unpaidAreIgnored: Bool
    private var canAutoDismiss: Bool = true
    
    
    weak var configStore: ConfigStore? = nil
    
    /// Gets the current scanning mode of the app - entry or exit
    private var scanMode: String {
        configStore!.scanMode
    }
    
    private var isExitMode: Bool {
        scanMode == "exit"
    }
    
    init(configuration: TicketStatusConfiguration) {
        self.secret = configuration.secret
        self.forcedRedeem = configuration.force
        self.unpaidAreIgnored = configuration.ignoreUnpaid
        self.questionAnswers = configuration.answers ?? []
        
        // get a reference to the application's current config store
        configStore = (UIApplication.shared.delegate as? AppDelegate)?.configStore
    }
    
    @MainActor
    private func announceResult(_ redemptionResponse: RedemptionResponse?, _ error: Error?) {
        // visual announcement
        announcement = TicketStatusAnnouncement(redemptionResponse, error, isExitMode, configStore!.checkInList!.includePending, isOffline: configStore!.ticketValidator!.isOnline != true)
        
        // haptic and sound announcements
        if !unpaidAreIgnored {
            configStore!.feedbackGenerator.announce(redemptionResponse: redemptionResponse, error, isExitMode)
        }
        
        self.isLoading = false
        startCountDown()
    }
    
    
    @Published var isLoading: Bool = true
    @Published var announcement: TicketStatusAnnouncement = .empty()
    @Published var askingQuestions: Bool = false
    @Published var questions: [Question] = []
    /// answer slots is a collection equal in size to the list of questions with `nil` value where no answer is present
    @Published var answerSlots: [Answer?] = []
    /// list of question answers
    @Published var questionAnswers: [Answer] = []
    
    
    func redeemUnpaid() {
        unpaidAreIgnored = true
        Task {
            await requestRedeem()
        }
    }
    
    @MainActor
    func redeem() async {
        await requestRedeem()
    }
    
    @MainActor
    func requestRedeem() async {
        isLoading = true
        askingQuestions = false
        
        let config = TicketStatusConfiguration(secret: secret, force: forcedRedeem, ignoreUnpaid: unpaidAreIgnored, answers: questionAnswers)
        do {
            let redemptionResponse = try await configStore!.ticketValidator!.redeem(configuration: config, as: scanMode)
            if let redemptionResponse, redemptionResponse.status == .incomplete {
                // we need to ask questions
                stopCountDown()
                updateQuestionsAndAnswers(redemptionResponse)
                showQuestions()
            } else {
                announceResult(redemptionResponse, nil)
            }
        } catch {
            announceResult(nil, error)
        }
    }
    
    @MainActor
    func cancelAnsweringCheckInQuestions() {
        closeView()
    }
    
    @MainActor
    func receivedAnswers(_ answers: [Answer]) {
        print("received answers, attempting to redeem again", answers)
        questionAnswers = answers
        Task {
            await redeem()
        }
    }
    
    @MainActor
    func showQuestions() {
        askingQuestions = true
    }
    
    @MainActor
    func updateQuestionsAndAnswers(_ redemptionResponse: RedemptionResponse) {
        questions = redemptionResponse.questions ?? []
        
        if let serverAnswers = redemptionResponse.answers {
            var mappedAnswers = [Answer?](repeating: nil, count: questions.count)
            for (index, question) in questions.enumerated() {
                if let answer = serverAnswers.filter({ $0.question.id == question.identifier }).first {
                    mappedAnswers[index] = answer
                }
            }
            answerSlots = mappedAnswers
        } else {
            answerSlots = [Answer?](repeating: nil, count: questions.count)
        }
    }
    
    @MainActor
    func closeView() {
        NotificationCenter.default.post(name: .init("CloseRedeemView"), object: nil)
    }
    
    @MainActor
    func stopCountDown() {
        canAutoDismiss = false
        NotificationCenter.default.post(name: .init("RedeemStopAutoDismissView"), object: nil)
    }
    
    @MainActor
    func startCountDown() {
        print("requesting countdown, can countdown: ", canAutoDismiss)
        // we can only request autodismiss once per ticket
        // once canceled the view stays open forever
        if canAutoDismiss {
            NotificationCenter.default.post(name: .init("RedeemStartAutoDismissView"), object: nil)
        }
    }
}
