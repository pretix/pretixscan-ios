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
        
        NotificationCenter.default.addObserver(self, selector: #selector(dismissVC), name: .init("CloseRedeemView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopAutoDismiss), name: .init("RedeemStopAutoDismissView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setupAutoDismiss), name: .init("RedeemStartAutoDismissView"), object: nil)
        
        // Add a tap gesture recognizer to stop any running autodismiss from taps
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(stopAutoDismiss))
        self.view.addGestureRecognizer(tapGesture)
        
        guard let configuration = configuration else {
            fatalError("ticket status configuration must be set")
        }
        
        // let SwiftUI take over
        let hostController = UIHostingController(rootView: RedeemTicketView(configuration: configuration))
        
        // but... it's autolayout's world, we're just redenring views in it
        hostController.view.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // add the SwiftUI host as a child controller
        addChild(hostController)
        view.addSubview(hostController.view)
        hostController.didMove(toParent: self)
        
        // activate constraints to center the SwiftUI view in the center
        hostController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        hostController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        hostController.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        hostController.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    @objc func setupAutoDismiss() {
        timer?.invalidate()
        print("starting count down")
        let delay = 15.0 // seconds
        let dismissTimer = Timer(timeInterval: delay, target: self, selector: #selector(dismissVC), userInfo: nil, repeats: false)
        RunLoop.main.add(dismissTimer, forMode: .common)
        timer = dismissTimer
    }
    

    @objc func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func stopAutoDismiss() {
        print("cancel timer \(timer != nil)")
        timer?.invalidate()
    }
}

extension TicketStatusController: UISheetPresentationControllerDelegate {
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        stopAutoDismiss()
    }
}
