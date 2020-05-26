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
            
            // Remove trailling new line
            if attributedSubstring(from: NSRange(location: range.location + range.length - 1, length: 1)).string == "\n" {
                range.length -= 1
            }
            
            // Create substring
            let attributedString = attributedSubstring(from: range)
            result.append(attributedString)
        }
        
        return result
    }
}




extension NSMutableAttributedString {
    
    func setFont(_ font: NSFont, color: NSColor? = nil) {
        beginEditing()
        self.enumerateAttribute(.font, in: NSRange(location: 0, length: self.length)) { (value, range, stop) in
            if let attrFont = value as? NSFont {
                updateFont(current: attrFont, new: font, in: range)
            }
            
            // Update color
            if let color = color {
                updateFontColor(to: color, in: range)
            }
        }
        endEditing()
    }
    
    
    func setFontColor(_ color: NSColor) {
        beginEditing()
        self.enumerateAttribute(.font, in: NSRange(location: 0, length: self.length)) { (value, range, stop) in
            updateFontColor(to: color, in: range)
        }
        endEditing()
    }
    
    
    private func updateFont(current currentFont: NSFont, new newFont: NSFont, in range: NSRange) {
        if let fontFamily = currentFont.familyName {
           let newFontDescriptor = currentFont.fontDescriptor
               .withFamily(fontFamily)
               .withSymbolicTraits(currentFont.fontDescriptor.symbolicTraits)
           
           if let updatedFont = NSFont(descriptor: newFontDescriptor, size: newFont.pointSize) {
               // Remove current font and add font with updated size
               removeAttribute(.font, range: range)
               addAttribute(.font, value: updatedFont, range: range)
            }
        }
    }
    
    
    private func updateFontColor(to newColor: NSColor, in range: NSRange) {
        removeAttribute(.foregroundColor, range: range)
        addAttribute(.foregroundColor, value: newColor, range: range)
    }
}
