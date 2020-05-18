//
//  NotesTextFormatter.swift
//  SlidePilot
//
//  Created by Pascal Braband on 12.05.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class NotesTextFormatter: NSObject {
    
    struct NotesTextUpdate {
        var text: NSMutableAttributedString
        var cursorPositon: NSRange
    }
    
    let listCharacter = "  •    "
    let listIndicatorCharacter = "- "
    let separator = "\n"
    
    
    /** Sets the font size, which will be used in the methods which return a `NotesTextUpdate`. */
    var fontSize: CGFloat = 12.0
    
    /** Sets the font color, which will be used in the methods which return a `NotesTextUpdate`. */
    var fontColor: NSColor = .black
    
    
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
    
    
    /**
     Formats the given text.
     
     - parameters:
        - text: The `String` which should be formatted.
        - currentSelection: The current cursor position. For `NSTextView` use the method `.selectedRange()`.
     
     - returns:
     A `NotesTextUpdate` which can be used to update the text and cursor position of `NSTextView`.
     */
    func format(_ text: String, currentSelection: NSRange) -> NotesTextUpdate {
        var newSelection = currentSelection
        
        let lines = text.components(separatedBy:  separator)
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
                    newSelection.location = currentSelection.location - listIndicatorCharacter.count + listCharacter.count
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
        
        return NotesTextUpdate(text: attributedString, cursorPositon: newSelection)
    }
    
    
    /**
     Modifes the given text for a given command
     
     - parameters:
        - text: The `NSAttributedString` which should be modified.
        - currentSelection: The current cursor position. For `NSTextView` use the method `.selectedRange()`.
        - commandSelector: A `Selector` which determines which modification to be performed.
     
     - returns:
     A `NotesTextUpdate` which can be used to update the text and cursor position of `NSTextView`.
     */
    func modify(_ text: NSAttributedString, currentSelection: NSRange, commandSelector: Selector) -> NotesTextUpdate? {
        // Compose mutable attributed string, which should be modified
        let modifyString = NSMutableAttributedString()
        modifyString.append(text)
        
        // Find current line
        let textViewContent = NSString(string: text.string)
        let currentLineRange = textViewContent.lineRange(for: currentSelection)
        let currentLine = textViewContent.substring(with: currentLineRange)
        
        // Did hit enter
        if commandSelector == #selector(NSResponder.insertNewline(_:)) {
            if currentLine.hasPrefix(listCharacter) {
                
                // Check if current line is empty (except list character)
                if currentLine == listCharacter || currentLine == listCharacter + "\n" {
                    return removeTrailingListCharacter(in: modifyString, currentLineRange: currentLineRange)
                }
                    
                // Line is not empty
                else {
                    return addTrailingListCharacter(in: modifyString, currentLineRange: currentLineRange, currentSelection: currentSelection)
                }
            }
        }
            
        // Did hit delete
        else if commandSelector == #selector(NSResponder.deleteBackward(_:)) {
            if currentSelection.location - currentLineRange.location == listCharacter.count {
                return removeTrailingListCharacter(in: modifyString, currentLineRange: currentLineRange)
            }
        }
        return nil
    }
    
    
    /**
     Removes the list character from the current line, if there is nothing else in it.
     
     - returns:
     `true` if something was changed, otherwise `false`.
     */
    func removeTrailingListCharacter(in text: NSMutableAttributedString, currentLineRange: NSRange) -> NotesTextUpdate {
        let currentLine = NSString(string: text.string).substring(with: currentLineRange)
        
        // Replace list character with empty line
        text.replaceCharacters(in: currentLineRange, with: NSAttributedString(string: currentLine.replacingOccurrences(of: listCharacter, with: ""), attributes: fontAttributes))
        
        // Set cursor to be at the beginning of the currentLine
        let newCursorPosition = NSRange(location: currentLineRange.location, length: 0)
        
        return NotesTextUpdate(text: text, cursorPositon: newCursorPosition)
    }
    
    
    /**
     Adds a new line with a trailling list character after the given current line.
     
     - parameters:
        - text: An `NSMutableAttributedString` which will be modified.
        - currentLineRange: `NSRange` of the current line. The line after which the new line should be inserted.
        - currentSelection: `NSRange` of the current cursor position. This is used to determine the new cursor position
     */
    func addTrailingListCharacter(in text: NSMutableAttributedString, currentLineRange: NSRange, currentSelection: NSRange) -> NotesTextUpdate {
        // Add list character to the new line
        let currentLocation = currentSelection.location
        let newLine = NSAttributedString(string: "\n" + listCharacter, attributes: [.paragraphStyle: paragraphStyle].merging(fontAttributes, uniquingKeysWith: { (current, _) in current }))
        text.insert(newLine, at: currentLocation)
        
        // Move cursor to end of list character
        let newCursorPosition = NSRange(location: currentSelection.location + 1 + listCharacter.count, length: 0)
        
        return NotesTextUpdate(text: text, cursorPositon: newCursorPosition)
    }
}
