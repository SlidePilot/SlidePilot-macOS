//
//  NotesTextProcessor.swift
//  SlidePilot
//
//  Created by Pascal Braband on 12.05.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class NotesTextProcessor: NSObject {
    
    let listCharacter = "  •    "
    let listIndicatorCharacter = "- "
    let separator = "\n"
    
    
    #if os(macOS)
    var textView: NSTextView!
    
    init(textView: NSTextView) {
        self.textView = textView
        super.init()
        textView.delegate = self
    }
    #endif
    
    
    var fontSize: CGFloat = 12.0 {
        didSet {
            textView.didChangeText()
        }
    }
    
    var fontColor: NSColor = .black {
        didSet {
            textView.didChangeText()
        }
    }
    
    var fontAttributes: [NSAttributedString.Key: Any] {
        var attributes = [NSAttributedString.Key: Any]()
        attributes[.font] = NSFont.systemFont(ofSize: fontSize)
        attributes[.foregroundColor] = fontColor
        return attributes
    }
    
    
    var paragraphStyle: NSMutableParagraphStyle {
        let p = NSMutableParagraphStyle()
        p.headIndent = (listCharacter as NSString).size(withAttributes: fontAttributes).width
        return p
    }
    
    
    func processText(string: String) -> (NSAttributedString, NSRange) {
        var currentSelection = textView.selectedRange()
        
        let lines = string.components(separatedBy:  separator)
            .flatMap { [$0, separator] }
            .dropLast()
        
        let attributedString = NSMutableAttributedString()
        
        // Go through every line and format it
        for line in lines {
            if line.hasPrefix(listIndicatorCharacter) {
                // Replace dash if there is one
                if let dashRange = line.range(of: listIndicatorCharacter) {
                    let newLine = line.replacingCharacters(in: dashRange, with: listCharacter)
                    let listItemLine = NSAttributedString(string: newLine, attributes: [.paragraphStyle: paragraphStyle])
                    attributedString.append(listItemLine)
                    
                    // Adjust selection
                    currentSelection.location = currentSelection.location - listIndicatorCharacter.count + listCharacter.count
                }
            } else if line.hasPrefix(listCharacter) {
                // Append existing items with the same paragraph style
                let listItemLine = NSAttributedString(string: line, attributes: [.paragraphStyle: paragraphStyle])
                attributedString.append(listItemLine)
            } else {
                attributedString.append(NSAttributedString(string: line))
            }
        }
        
        // Add font from attributes
        attributedString.addAttributes(fontAttributes, range: NSRange(location: 0, length: attributedString.length))
        
        return (attributedString, currentSelection)
    }

}




extension NotesTextProcessor: NSTextViewDelegate {
    
    func textDidChange(_ notification: Notification) {
        // Update text and set correct position
        let (res, selection) = processText(string: textView.string)
        textView.textStorage?.setAttributedString(res)
        textView.setSelectedRange(selection)
    }
    
    
    func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if textView == self.textView {
            // Compose mutable attributed string, which should be modified
            let attributedString = textView.attributedString()
            let modifyString = NSMutableAttributedString()
            modifyString.append(attributedString)
            
            // Find current line
            let textViewContent = NSString(string: textView.string)
            let currentSelection = textView.selectedRange()
            let currentLineRange = textViewContent.lineRange(for: currentSelection)
            let currentLine = textViewContent.substring(with: currentLineRange)
            
            // Did hit enter
            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                if currentLine.hasPrefix(listCharacter) {
                    
                    // Check if current line is empty (except list character)
                    if currentLine == listCharacter || currentLine == listCharacter + "\n" {
                        removeTrailingListCharacter(in: modifyString, currentLineRange: currentLineRange)
                        return true
                    }
                    
                    // Line is not empty
                    else {
                        addTrailingListCharacter(in: modifyString, currentLineRange: currentLineRange, currentSelection: currentSelection)
                        return true
                    }
                }
            }
            
            // Did hit delete
            else if commandSelector == #selector(NSResponder.deleteBackward(_:)) {
                if currentLine == listCharacter || currentLine == listCharacter + "\n" {
                    removeTrailingListCharacter(in: modifyString, currentLineRange: currentLineRange)
                    return true
                }
            }
        }
        return false
    }
    
    
    /**
     Removes the list character from the current line, if there is nothing else in it.
     
     - returns:
     `true` if something was changed, otherwise `false`.
     */
    func removeTrailingListCharacter(in string: NSMutableAttributedString, currentLineRange: NSRange) {
        let currentLine = NSString(string: textView.string).substring(with: currentLineRange)
        
        // Replace list character with empty line
        string.replaceCharacters(in: currentLineRange, with: NSAttributedString(string: currentLine.replacingOccurrences(of: listCharacter, with: ""), attributes: [.font: NSFont.systemFont(ofSize: 16.0)]))
        textView.textStorage?.setAttributedString(string)
        
        // Set cursor to be at the beginning of the currentLine
        textView.setSelectedRange(NSRange(location: currentLineRange.location, length: 0))
    }
    
    
    func addTrailingListCharacter(in string: NSMutableAttributedString, currentLineRange: NSRange, currentSelection: NSRange) {
        // Add list character to the new line
        let currentLocation = textView.selectedRanges[0].rangeValue.location
        let newLine = NSAttributedString(string: "\n" + listCharacter, attributes: [.paragraphStyle: paragraphStyle, .font: NSFont.systemFont(ofSize: 16.0)])
        string.insert(newLine, at: currentLocation)
        
        textView.textStorage?.setAttributedString(string)
        textView.setSelectedRange(NSRange(location: currentSelection.location + 1 + listCharacter.count, length: 0))
    }
}
