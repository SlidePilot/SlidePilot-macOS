//
//  NSAttributedString+Extension.swift
//  SlidePilot
//
//  Created by Pascal Braband on 24.05.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

extension NSAttributedString {
    
    /** Returns the components, which are separated by the strings, that match the `pattern`. */
    func components(separatedByExpression pattern: String) -> [NSAttributedString] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return [NSAttributedString]() }
        
        let matches = regex.matches(in: self.string, range: NSMakeRange(0, self.string.utf16.count))
        
        var result = [NSAttributedString]()
        // Split attributes
        for (i, separator) in matches.enumerated() {
            // Calculate location of component start
            var range = NSRange(location: 0, length: 0)
            range.location = separator.range.location + separator.range.length
            
            // Calculate length of component
            if i == matches.count - 1 {
                range.length = self.string.utf16.count - range.location
            } else {
                range.length = matches[i+1].range.location - range.location
            }
            
            // Create substring
            let attributedString = attributedSubstring(from: range)
            result.append(attributedString)
        }
        
        return result
    }
}
