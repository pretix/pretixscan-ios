//
//  SetupFinishedViewController.swift
//  PretixScan
//
//  Created by Daniel Jilg on 18.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class SetupFinishedViewController: UIViewController, Configurable {
    var configStore: ConfigStore?

    @IBOutlet private weak var confimationIcon: UILabel!
    @IBOutlet private weak var explanationLabel: UILabel!
    @IBOutlet private weak var dismissButton: UIButton!
    @IBOutlet private weak var eventLabel: UILabel!
    @IBOutlet private weak var checkInListLabel: UILabel!
    @IBOutlet weak var eventPreviewView: UIView!
    @IBOutlet weak var eventPreviewBackgroundView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = Localization.SetupFinishedViewController.Title
        explanationLabel.text = Localization.SetupFinishedViewController.Explanation
        dismissButton.setTitle(Localization.SetupFinishedViewController.Dismiss, for: .normal)

        eventPreviewView.layer.masksToBounds = true
        eventPreviewView.layer.cornerRadius = Style.cornerRadius
        eventPreviewView.layer.borderColor = UIColor.lightGray.cgColor
        eventPreviewView.layer.borderWidth = 0.5
        eventPreviewBackgroundView.backgroundColor = PXColor.okay
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        eventLabel.text = configStore?.event?.name.representation(in: Locale.current) ?? "No Event"
        checkInListLabel.text = configStore?.checkInList?.name ?? "No CheckInList"
    }

    @IBAction func dismiss(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
