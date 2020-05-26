//
//  NotesTextView.swift
//  SlidePilot
//
//  Created by Pascal Braband on 24.05.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class NotesTextView: NSTextView {
    
    
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
        self.isRichText = true
        self.importsGraphics = false
        self.allowsUndo = true
        
        // Subscribe to changes
        DocumentController.subscribeNewNotes(target: self, action: #selector(didCreateNewNotes(_:)))
        DocumentController.subscribeDidOpenNotes(target: self, action: #selector(didOpenNotes(_:)))
        PageController.subscribe(target: self, action: #selector(pageDidChange(_:)))
        
        reloadContent()
    }
    
    
    override func didChangeText() {
        super.didChangeText()
        
        let notes = self.attributedString().copy() as! NSAttributedString
        _ = DocumentController.notesDocument?.set(notes: notes, on: PageController.currentPage)
    }
    
    
    func reloadContent() {
        // Reload the contents in the textview with the current page and the current notes document
        
        // Restore font color and size
        let previousColor = self.textColor
        //let previousFont = self.font
        
        guard let notesDocument = DocumentController.notesDocument,
            PageController.currentPage < notesDocument.contents.count else { return }
        let notes = notesDocument.contents[PageController.currentPage]
        self.textStorage?.setAttributedString(notes)
        
        self.textColor = previousColor
        //self.font = previousFont
    }
    
    
    @objc func didCreateNewNotes(_ notification: Notification) {
        reloadContent()
    }
    
    
    @objc func didOpenNotes(_ notification: Notification) {
        reloadContent()
    }
    
    
    @objc func pageDidChange(_ notification: Notification) {
        reloadContent()
    }
}
