//
//  ImageResize.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 26/02/2022.
//  Copyright © 2022 rami.io. All rights reserved.
//

import CoreGraphics
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
        let rect = CGRect(origin: .zero, size: targetSize)
        
        defer {
            UIGraphicsEndImageContext()
        }
        
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        self.normalizeOrientation().draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        return newImage
    }
}
