//
//  NotesTextView.swift
//  SlidePilot
//
//  Created by Pascal Braband on 12.05.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class NotesTextView: NSTextView {
    
    var shouldInsertText = false
    var notesProcessor: NotesTextFormatter!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    
    override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
        super.init(frame: frameRect, textContainer: container)
        setup()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    
    func setup() {
        notesProcessor = NotesTextFormatter(textView: self)
    }
    
    
    func increaseFontSize() {
        guard let currentFontSize = self.font?.pointSize else { return }
        setFontSize(currentFontSize + 1.0)
    }
    
    
    func decreaseFontSize() {
        guard let currentFontSize = self.font?.pointSize else { return }
        setFontSize(currentFontSize - 1.0)
    }
    
    
    func setFontSize(_ fontSize: CGFloat) {
        self.font = NSFont.systemFont(ofSize: fontSize)
        notesProcessor.fontSize = fontSize
    }
    
    
    func setFontColor(_ fontColor: NSColor) {
        notesProcessor.fontColor = fontColor
        
        if fontColor == .white {
            self.insertionPointColor = .white
        } else {
            self.insertionPointColor = .black
        }
    }
}

