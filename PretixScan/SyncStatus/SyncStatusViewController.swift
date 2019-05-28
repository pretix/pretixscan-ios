//
//  SyncStatusViewController.swift
//  PretixScan
//
//  Created by Daniel Jilg on 02.05.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class SyncStatusViewController: UIViewController {
    @IBOutlet private weak var detailLabel: UILabel!
    @IBOutlet private weak var progressView: UIProgressView!
    private var updateTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(syncDownloadStatusUpdate(_:)),
                                               name: SyncManager.syncStatusUpdateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(syncBegan(_:)),
                                               name: SyncManager.syncBeganNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(syncEnded(_:)),
                                               name: SyncManager.syncEndedNotification, object: nil)

        updateTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in self.updateStatusDisplay() }
    }

    @objc
    func syncBegan(_ notification: Notification) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
    }

    @objc
    func syncEnded(_ notification: Notification) {
        print("sync ended")
        let lastSyncDate = notification.userInfo?[SyncManager.NotificationKeys.lastSyncDate] as? Date

        DispatchQueue.main.async {
            self.detailLabel.text = "Syncing Done: \(lastSyncDate ?? Date())"
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }

    var previouslyLoadedAmounts = [String: Int]()

    @objc
    func syncDownloadStatusUpdate(_ notification: Notification) {
        let model: String = notification.userInfo?[SyncManager.NotificationKeys.model] as? String ?? "No Model"
        let loadedAmount = notification.userInfo?[SyncManager.NotificationKeys.loadedAmount] as? Int ?? 0
        let totalAmount = notification.userInfo?[SyncManager.NotificationKeys.totalAmount] as? Int ?? 0
        let isLastPage = notification.userInfo?[SyncManager.NotificationKeys.isLastPage] as? Bool ?? false
        let previouslyLoadedAmount = previouslyLoadedAmounts[model, default: 0]

        if isLastPage {
            // reset load counter
            previouslyLoadedAmounts[model] = nil
        } else {
            previouslyLoadedAmounts[model] = previouslyLoadedAmount + loadedAmount
        }

        DispatchQueue.main.async {
            self.detailLabel.text = "\(model) updated, added \(previouslyLoadedAmount + loadedAmount)/\(totalAmount)."
            let progress = Float(previouslyLoadedAmount + loadedAmount) / Float(totalAmount)
            self.progressView.setProgress(progress, animated: true)
        }
    }

    private func updateStatusDisplay() {
    }
}
