//
//  SceneDelegate.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 26/10/2023.
//  Copyright © 2023 rami.io. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        UIButton.appearance().tintColor = PXColor.buttons
        UIProgressView.appearance().tintColor = PXColor.buttons
        UIActivityIndicatorView.appearance().tintColor = PXColor.buttons
        UIView.appearance().tintColor = PXColor.buttons
    }
}

