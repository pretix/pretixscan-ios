//
//  QuestionsView.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 16/11/2023.
//  Copyright © 2023 rami.io. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

struct QuestionsView: UIViewControllerRepresentable {
    
    let configStore: ConfigStore
    let questions: [Question]
    let answers: [Answer?]
    
    var onCancelAnswering: (() -> ())?
    var onAnswered: (([Answer]) -> ())?
    
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // nothing to do
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let questionsController = QuestionsTableViewController(style: .plain)
        questionsController.configStore = configStore
        questionsController.questions = questions
        questionsController.answers = answers
        
        questionsController.delegate = context.coordinator
        
        let nav = UINavigationController(rootViewController: questionsController)
        nav.navigationBar.prefersLargeTitles = true
        return nav
    }
    
    
    class Coordinator: NSObject, QuestionsTableViewControllerDelegate {
        var parent: QuestionsView
        
        init(_ controller: QuestionsView) {
            parent = controller
        }
        
        func cancelAnsweringCheckInQuestions() {
            parent.onCancelAnswering?()
        }
        
        func receivedAnswers(_ answers: [Answer]) {
            parent.onAnswered?(answers)
        }
    }
}

