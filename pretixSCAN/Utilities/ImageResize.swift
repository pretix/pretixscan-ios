//
//  ImageResize.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 26/02/2022.
//  Copyright © 2022 rami.io. All rights reserved.
//

import UIKit

public extension UIImage {
    func normalizeOrientation() -> UIImage {
        guard imageOrientation != .up else { return self }
        UIGraphicsBeginImageContext(size)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage ?? self
    }
    
    func resize(to targetSize: CGSize) -> UIImage? {
        let image = self

        // Compute the scaling ratio for the width and height separately
        let widthScaleRatio = targetSize.width / image.size.width
        let heightScaleRatio = targetSize.height / image.size.height

        // To keep the aspect ratio, scale by the smaller scaling ratio
        let scaleFactor = max(widthScaleRatio, heightScaleRatio)

        // Multiply the original image’s dimensions by the scale factor
        // to determine the scaled image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: image.size.width * scaleFactor,
            height: image.size.height * scaleFactor
        )
        
        if scaledImageSize.width < targetSize.width || scaledImageSize.height < targetSize.height {
            return image
        }
        
        let rect = CGRect(origin: .zero, size: scaledImageSize)
        
        defer {
            UIGraphicsEndImageContext()
        }
        
        UIGraphicsBeginImageContextWithOptions(scaledImageSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        return newImage
    }
    
    func resizeAndCrop(to newSize: CGSize) -> UIImage {
        let normalized = self.normalizeOrientation()
        let resized = normalized.resize(to: newSize)!
        let cropped = resized.crop(to: newSize)
        return cropped
    }
    
    func crop(to newSize: CGSize) -> UIImage {
        let cgimage = self.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        let contextSize: CGSize = contextImage.size
        
        if newSize == contextSize {
            return self
        }
        
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        let cgwidth: CGFloat = CGFloat(newSize.width)
        let cgheight: CGFloat = CGFloat(newSize.height)
        
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
        }
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = cgimage.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        
        return image
    }
}
