//
//  PXImagePickerController.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 10/03/2022.
//  Copyright © 2022 rami.io. All rights reserved.
//

import UIKit

class PXImagePickerController: UIImagePickerController {
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.cameraOverlayView?.setNeedsDisplay()
    }
}
