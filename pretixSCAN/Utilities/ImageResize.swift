//
//  ImageResize.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 26/02/2022.
//  Copyright © 2022 rami.io. All rights reserved.
//

import CoreGraphics
import UIKit

extension UIImage {
    
    func normalizedImage() -> UIImage? {
        //        if (self.imageOrientation == UIImage.Orientation.up) {
        //            // no need to change orientation
        //            return self
        //        }
        //
        guard let cgImage = self.cgImage else {
            logger.warning("CGImage not available during normalize.")
            return nil
        }
        
        guard let colorSpace = cgImage.colorSpace, let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            logger.warning("Failed to create CGContext during normalize.")
            return nil
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
        case .up, .upMirrored:
            break
        @unknown default:
            logger.warning("Unknown orientation \(String(describing: self.imageOrientation)) during normalize.")
            return nil
        }
        
        // Flip image one more time if needed to, this is to prevent flipped image
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        @unknown default:
            logger.warning("Unknown orientation \(String(describing: self.imageOrientation)) during normalize.")
            return nil
        }
        
        ctx.concatenate(transform)
        
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }
        
        guard let newCGImage = ctx.makeImage() else { return nil }
        return UIImage.init(cgImage: newCGImage, scale: 1, orientation: .up)
    }
}

/// Extension methods offering several techniques to resize an image
extension CGImage {
    
    public enum ResizeError: Error {
        case cgContextCreationFailed
    }
    
    /// Resize image from given size.
    ///
    /// - Parameter newSize: Size of the image output.
    /// - Returns: Resized image.
    public func resized(to newSize: CGSize) throws -> CGImage {
        return try self.resizeWithCoreGraphics(to: newSize)
    }
    
    // MARK: - CoreGraphics
    
    private func resizeWithCoreGraphics(to newSize: CGSize) throws -> CGImage {
        guard let colorSpace = self.colorSpace,
              let context = CGContext(data: nil,
                                      width: Int(newSize.width),
                                      height: Int(newSize.height),
                                      bitsPerComponent: self.bitsPerComponent,
                                      bytesPerRow: self.bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: self.bitmapInfo.rawValue)
        else { throw ResizeError.cgContextCreationFailed }
        context.interpolationQuality = .high
        
        context.draw(self,
                     in: .init(origin: .zero,
                               size: newSize))
        
        guard let resultCGImage = context.makeImage()
        else { throw ResizeError.cgContextCreationFailed }
        
        return resultCGImage
    }
}
