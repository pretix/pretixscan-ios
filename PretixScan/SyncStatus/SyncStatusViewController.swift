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
    private var previouslyLoadedAmounts = [String: Int]()
    private lazy var dateFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.minute]
        return formatter
    }()

    private enum SyncStatus {
        case neverSynced
        case syncing(model: String, loaded: Int, total: Int)
        case syncEnded(lastSyncDate: Date?)
    }
    private var currentSyncStatus: SyncStatus = .neverSynced {
        didSet {
            DispatchQueue.main.async { self.updateStatusDisplay() }
        }
    }

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
    }

    @objc
    func syncEnded(_ notification: Notification) {
        currentSyncStatus = .syncEnded(lastSyncDate: notification.userInfo?[SyncManager.NotificationKeys.lastSyncDate] as? Date)
    }

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

        currentSyncStatus = .syncing(model: model, loaded: previouslyLoadedAmount + loadedAmount, total: totalAmount)
    }

    private func updateStatusDisplay() {
        switch currentSyncStatus {
        case .neverSynced:
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        case .syncing(let model, let loaded, let total):
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            self.detailLabel.text = "\(model) updated, added \(loaded)/\(total)."
            let progress = Float(loaded) / Float(total)
            self.progressView.setProgress(progress, animated: true)
        case .syncEnded(let lastSyncDate):
            if let lastSyncDate = lastSyncDate {
                let lastSyncTimeInterval = -lastSyncDate.timeIntervalSinceNow
                let timeIntervalString = lastSyncTimeInterval < 60 ? Localization.SyncStatusViewController.LessThanAMinute :
                    "\(dateFormatter.string(from: lastSyncTimeInterval)!)"
                detailLabel.text = String.localizedStringWithFormat(Localization.SyncStatusViewController.LastSyncXAgo, timeIntervalString)
            } else {
                detailLabel.text = Localization.SyncStatusViewController.SyncingDone
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
}
