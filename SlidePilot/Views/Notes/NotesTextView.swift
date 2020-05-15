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
        self.allowsUndo = true
        notesProcessor = NotesTextFormatter(textView: self)
        
        // Subscribe to changes, when text view needs to update content
        DocumentController.subscribeFinishedImportingNotes(target: self, action: #selector(didImportNotes(_:)))
        PageController.subscribe(target: self, action: #selector(didSelectPage(_:)))
        
        // Subscribe to display changes
        DisplayController.subscribeIncreaseFontSize(target: self, action: #selector(didIncreaseFontSize(_:)))
        DisplayController.subscribeDecreaseFontSize(target: self, action: #selector(didDecreaseFontSize(_:)))
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
    
    
    func updateContent() {
        guard let currentPage = DocumentController.document?.page(at: PageController.currentPage) else { return }
        guard let notesText = NotesAnnotation.getNotesText(on: currentPage) else { return }
        self.string = notesText
        self.didChangeText()
    }
    
    
    
    
    // MARK: - Control Handlers
    
    
    @objc func didImportNotes(_ notification: Notification) {
        updateContent()
    }
    
    
    @objc func didSelectPage(_ notification: Notification) {
        updateContent()
    }
    
    
    @objc func didIncreaseFontSize(_ notification: Notification) {
        increaseFontSize()
    }
    
    
    @objc func didDecreaseFontSize(_ notification: Notification) {
        decreaseFontSize()
    }
}

