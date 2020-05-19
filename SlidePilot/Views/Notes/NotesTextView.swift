//
//  NotesTextView.swift
//  SlidePilot
//
//  Created by Pascal Braband on 12.05.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class NotesTextView: NSTextView {
    
    let fontSizeDefaultsKey = "notesEditorFontSize"
    let defaultFontSize: CGFloat = 16.0
    
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
        notesProcessor = NotesTextFormatter()
        
        // Subscribe to document save request
        DocumentController.subscribeRequestSaveDocument(target: self, action: #selector(saveDocument(_:)))
        
        // Subscribe to changes, when text view needs to update content
        DocumentController.subscribeFinishedImportingNotes(target: self, action: #selector(didImportNotes(_:)))
        PageController.subscribeWillSelectPage(target: self, action: #selector(willSelectPage(_:)))
        PageController.subscribeDidSelectPage(target: self, action: #selector(didSelectPage(_:)))
        
        // Subscribe to display changes
        DisplayController.subscribeIncreaseFontSize(target: self, action: #selector(didIncreaseFontSize(_:)))
        DisplayController.subscribeDecreaseFontSize(target: self, action: #selector(didDecreaseFontSize(_:)))
        
        // Set initial font size, either saved from UserDefaults or default size
        if let userFontSize = UserDefaults.standard.value(forKey: fontSizeDefaultsKey) as? CGFloat {
            setFontSize(userFontSize)
        } else {
            setFontSize(defaultFontSize)
        }
        
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
        UserDefaults.standard.set(fontSize, forKey: fontSizeDefaultsKey)
        update(with: self.string, reportModification: false)
    }
    
    
    func setFontColor(_ fontColor: NSColor) {
        notesProcessor.fontColor = fontColor
        
        if fontColor == .white {
            self.insertionPointColor = .white
        } else {
            self.insertionPointColor = .black
        }
        update(with: self.string, reportModification: false)
    }
    
    
    
    
    // MARK: - Update Methods
    
    /**
     Formats the given string and puts it in the text view (self).
     
     - parameters:
        - text: The `String` which should be formatted.
        - reportModification: A boolean value indicating, whether the modification should be reported with a notification.
     */
    func update(with text: String, reportModification: Bool) {
        let notesUpdate = notesProcessor.format(text, currentSelection: self.selectedRange())
        performUpdate(notesUpdate, reportModification: reportModification)
    }
    
    
    func performUpdate(_ update: NotesTextFormatter.NotesTextUpdate, reportModification: Bool) {
        // Send didEditDocument notification if requested
        if reportModification {
            DocumentController.didEditDocument(sender: self)
        }
        
        self.undoManager?.beginUndoGrouping()
        self.textStorage?.setAttributedString(update.text)
        self.setSelectedRange(update.cursorPositon)
        self.undoManager?.endUndoGrouping()
    }
    
    
    /**
     Reloads the notes from the annotations and puts them in the text view (self).
     */
    func reloadNotes(reportModification: Bool) {
        guard let currentPage = DocumentController.document?.page(at: PageController.currentPage) else { return }
        let notesText = NotesAnnotation.getNotesText(on: currentPage) ?? ""
        
        // Update text
        update(with: notesText, reportModification: reportModification)
    }
    
    
    override func didChangeText() {
        super.didChangeText()
        update(with: self.string, reportModification: true)
    }
    
    
    override func doCommand(by selector: Selector) {
        // Update the notes text for the given command
        if let notesUpdate = notesProcessor.modify(self.attributedString(), currentSelection: self.selectedRange(), commandSelector: selector) {
            performUpdate(notesUpdate, reportModification: true)
        } else {
            super.doCommand(by: selector)
        }
    }
    
    
    /**
     Writes the content to the notes annotation of the current page of the PDF document.
     
    - parameters:
        - shouldSave: A boolean value indicating, whether the PDF should be saved.
     */
    func write(shouldSave: Bool) {
        let success = NotesAnnotation.writeToCurrentPage(self.string, save: shouldSave)
        if shouldSave {
            DocumentController.didSaveDocument(success: success, sender: self)
        }
    }
    
    
    
    
    // MARK: - Control Handlers
    
    
    @objc func saveDocument(_ notification: Notification) {
        write(shouldSave: true)
    }
    
    
    @objc func didImportNotes(_ notification: Notification) {
        reloadNotes(reportModification: false)
    }
    
    
    @objc func willSelectPage(_ notification: Notification) {
        write(shouldSave: false)
    }
    
    
    @objc func didSelectPage(_ notification: Notification) {
        reloadNotes(reportModification: false)
    }
    
    
    @objc func didIncreaseFontSize(_ notification: Notification) {
        increaseFontSize()
    }
    
    
    @objc func didDecreaseFontSize(_ notification: Notification) {
        decreaseFontSize()
    }
}
