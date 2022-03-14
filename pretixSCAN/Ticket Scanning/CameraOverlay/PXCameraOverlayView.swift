//
//  PXCameraOverlayView.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 10/03/2022.
//  Copyright © 2022 rami.io. All rights reserved.
//

import UIKit

final class PXCameraOverlayView: UIView {
    weak var imagePicker: UIViewController?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let ip = imagePicker else {
            return
        }
        self.frame = ip.view.frame
        let overlayFrame = calculateOverlayFrame(frame: ip.view.frame)
        
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        ctx.setStrokeColor(PXColor.primaryGreen.cgColor)
        ctx.stroke(overlayFrame, width: 4)
    }
    
    func calculateOverlayFrame(frame: CGRect) -> CGRect {
        let scaleRatio = FileUploadQuestionCell.UploadSize.width / FileUploadQuestionCell.UploadSize.height
        
        // the overlay will be inlined by 20pt
        let scaledW = frame.size.height * scaleRatio - 20
        let scaledH = frame.size.width / scaleRatio - 20
        
        let posX = frame.width / 2 - scaledW / 2
        let posY = frame.height / 2 - scaledH / 2
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: scaledW, height: scaledH)
        logger.debug("📸 camera overlay rectangle \(String(describing: rect))")
        return rect
    }
}
