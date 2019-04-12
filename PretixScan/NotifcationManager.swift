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
        NotificationCenter.default.addObserver(self, selector: #selector(syncStatusUpdate(_:)),
                                               name: configStore.syncManager.syncStatusUpdateNotification, object: nil)
    }

    @objc
    func configStoreChanged(_ notification: Notification) {
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

    @objc
    func syncStatusUpdate(_ notification: Notification) {
        let model: String = notification.userInfo?[SyncManager.NotificationKeys.model] as? String ?? "No Model"
        let loadedAmount = notification.userInfo?[SyncManager.NotificationKeys.loadedAmount] as? Int ?? -1
        let totalAmount = notification.userInfo?[SyncManager.NotificationKeys.totalAmount] as? Int ?? -1
        let isLastPage = notification.userInfo?[SyncManager.NotificationKeys.isLastPage] as? Bool ?? false

        print("\(model) updated, added \(loadedAmount)/\(totalAmount).")

        if isLastPage {
            print("Finished syncing \(model).")
        }
    }
}
