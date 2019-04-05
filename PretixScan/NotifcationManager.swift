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
        NotificationCenter.default.addObserver(self, selector: #selector(configStoreReset(_:)),
                                               name: configStore.resetNotification, object: nil)
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
    func configStoreReset(_ notification: Notification) {
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
