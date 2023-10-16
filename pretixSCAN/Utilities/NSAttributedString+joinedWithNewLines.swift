//
//  NSAttributedString+joinedWithNewLines.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 16/10/2023.
//  Copyright © 2023 rami.io. All rights reserved.
//

import Foundation

extension Array where Element: NSAttributedString {
    /// Merges the collection of `NSAttributedString` instances into a new one, one per line.
    ///
    ///
    /// Usage:
    ///
    ///```swift
    ///    let attributedStrings: [NSAttributedString] = [
    ///        NSAttributedString(string: "Hello", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red]),
    ///        NSAttributedString(string: "World", attributes: [NSAttributedString.Key.foregroundColor: UIColor.blue])
    ///    ]
    ///
    ///    let combinedString = attributedStrings.joinedWithNewlines()
    ///    print(combinedString)
    ///```
    ///
    func joinedWithNewlines() -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        for (index, element) in enumerated() {
            result.append(element)
            
            if index < count - 1 { // Append newline if it's not the last element
                let newline = NSAttributedString(string: "\n")
                result.append(newline)
            }
        }
        
        return result
    }
}

