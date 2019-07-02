//
//  NotifcationManager.swift
//  PretixScan
//
//  Created by Daniel Jilg on 04.04.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit
import SwiftMessages

class NotificationManager {
    private var configStore: ConfigStore

    init(configStore: ConfigStore) {
        self.configStore = configStore
        NotificationCenter.default.addObserver(self, selector: #selector(configStoreChanged(_:)),
                                               name: configStore.changedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(configStoreFactoryReset(_:)),
                                               name: configStore.resetNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(syncDownloadStatusUpdate(_:)),
                                               name: SyncManager.syncStatusUpdateNotification, object: nil)
    }

    @objc
    func configStoreChanged(_ notification: Notification) {
        DispatchQueue.main.async {
            if let value = notification.userInfo?["value"] as? ConfigStoreValue {

                if value == .asyncModeEnabled {
                    SwiftMessages.hideAll()
                    SwiftMessages.show {
                        let view = MessageView.viewFromNib(layout: .statusLine)
                        view.configureTheme(backgroundColor: Color.okay, foregroundColor: Color.primaryText)
                        view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

                        if self.configStore.asyncModeEnabled {
                            view.configureContent(body: Localization.NotificationManager.SyncModeOffline)
                        } else {
                            view.configureContent(body: Localization.NotificationManager.SyncModeOnline)
                        }
                        return view
                    }
                } else if value == .shouldAutoSync {
                    SwiftMessages.hideAll()
                    SwiftMessages.show {
                        let view = MessageView.viewFromNib(layout: .statusLine)
                        view.configureTheme(backgroundColor: Color.okay, foregroundColor: Color.primaryText)
                        view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

                        if self.configStore.shouldAutoSync {
                            view.configureContent(body: Localization.NotificationManager.ShouldAutoSyncOn)
                        } else {
                            view.configureContent(body: Localization.NotificationManager.ShouldAutoSyncOff)
                        }
                        return view
                    }
                }
            }
        }
    }

    @objc
    func configStoreFactoryReset(_ notification: Notification) {
        SwiftMessages.hideAll()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // we wait for 2 seconds so the application can settle down and reset its UI before we show the alert
            SwiftMessages.show {
                let view = MessageView.viewFromNib(layout: .statusLine)
                view.configureTheme(backgroundColor: Color.warning, foregroundColor: Color.primaryText)
                view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
                view.configureContent(body: Localization.NotificationManager.Reset)
                return view
            }
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

        print("\(model) updated, added \(previouslyLoadedAmount + loadedAmount)/\(totalAmount).")

        if isLastPage {
            print("Finished syncing \(model).")
        }
    }
}
