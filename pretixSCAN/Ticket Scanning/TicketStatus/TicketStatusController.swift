//
//  TicketStatusController.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 14/11/2023.
//  Copyright © 2023 rami.io. All rights reserved.
//

import UIKit
import SwiftUI

class TicketStatusController: UIViewController {
    weak var timer: Timer? = nil
    var configuration: TicketStatusConfiguration? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
//        setupAutoDismiss()
        
        guard let configuration = configuration else {
            fatalError("ticket status configuration must be set")
        }
        
        // let SwiftUI take over
        let hostController = UIHostingController(rootView: RedeemTicketView(configuration: configuration))
        addChild(hostController)
        view.addSubview(hostController.view)
        hostController.view.frame = view.bounds
        hostController.didMove(toParent: self)
    }
    
    func setupAutoDismiss() {
        let delay = 5.0 // seconds
        let dismissTimer = Timer(timeInterval: delay, target: self, selector: #selector(dismissVC), userInfo: nil, repeats: false)
        RunLoop.main.add(dismissTimer, forMode: .common)
        timer = dismissTimer
        
        // Add a tap gesture recognizer to the view controller's view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(stopAutoDismiss))
        self.view.addGestureRecognizer(tapGesture)
    }
    

    @objc func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func stopAutoDismiss() {
        print("cancel timer \(timer != nil)")
        // Invalidate the timer when the user taps the screen
        timer?.invalidate()
    }
}

extension TicketStatusController: UISheetPresentationControllerDelegate {
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        stopAutoDismiss()
    }
}
