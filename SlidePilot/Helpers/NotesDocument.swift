//
//  NotesDocument.swift
//  SlidePilot
//
//  Created by Pascal Braband on 24.05.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class NotesDocument: NSObject {
    
    private(set) var contents: [NSAttributedString] = [NSAttributedString]()
    private(set) var url: URL?
    var isDocumentEdited: Bool {
        didSet {
            if isDocumentEdited {
                DocumentController.didEditNotes(sender: self)
            }
        }
    }
    
    
    /**
     Initializes the document with the contents of the file at the given URL.
     
     - returns:
     `nil` if loading the file failed.
     */
    init?(contentsOf fileURL: URL, pageCount: Int) {
        self.url = fileURL
        self.isDocumentEdited = false
        super.init()
        
        // Load contents
        if !load(fileURL: fileURL) {
            return nil
        }
        // Fill up contents if necessary (if not enough notes were loaded)
        fillContents(to: pageCount)
    }
    
    
    /**
     Intializes an empty notes document.
     */
    init(pageCount: Int) {
        self.url = nil
        self.isDocumentEdited = false
        
        super.init()
        
        fillContents(to: pageCount)
    }
    
    
    /**
     Sets the notes for a specified page.
     
     - returns:
     `true` if setting value was successfull, otherwise `false`.
     */
    func set(notes: NSAttributedString, on pageIndex: Int) -> Bool {
        guard 0 <= pageIndex, pageIndex < contents.count else { return false }
        contents[pageIndex] = notes
        
        // New unsaved changes
        isDocumentEdited = true
        
        return true
    }
    
    
    /**
     Load the contents of the file at the given URL into `content`.
     
     - returns:
     `true` if loading was successfull, otherwise `false`.
     */
    private func load(fileURL: URL) -> Bool {
        // Load file
        guard let fileContents = try? NSAttributedString(url: fileURL, options: [:], documentAttributes: nil) else { return false }
        
        // Split contents page wise
        contents = fileContents.components(separatedByExpression: "#SLIDEPILOT-NOTES-PAGE-SEPARATOR#-Page-[0-9]*\n")
        
        return true
    }
    
    
    /**
     Saves the `contents` to the file at the specified path
     */
    func save(to fileURL: URL) -> Bool {
        let output = NSMutableAttributedString()
        for (i, pageContent) in contents.enumerated() {
            output.append(NSAttributedString(string: "#SLIDEPILOT-NOTES-PAGE-SEPARATOR#-Page-\(i+1)\n"))
            output.append(pageContent)
            output.append(NSAttributedString(string: "\n"))
        }
        
        // Save notes with black font color
        output.setFontColor(.black)
        
        guard let outputData = output.rtf(from: NSRange(location: 0, length: output.length), documentAttributes: [.documentType: NSAttributedString.DocumentType.html]) else { return false }
        do {
            try outputData.write(to: fileURL)
            self.url = fileURL
        } catch _ {
            return false
        }
        
        // All changes were saved
        isDocumentEdited = false
        
        return true
    }
    
    
    /**
     Saves the `contents` to the file specified in the `url` property.
     */
    func save() -> Bool {
        guard self.url != nil else { return false }
        return save(to: self.url!)
    }
    
    
    /** Fills the `contents` array with empty `NSAttributed`, until the `targetCount` is reached. */
    func fillContents(to targetCount: Int) {
        while contents.count < targetCount {
            contents.append(NSAttributedString(string: ""))
        }
    }
    
    
    
    
    // MARK: Modify
    
    func setFontSize(to pointSize: CGFloat) {
        for (i, item) in contents.enumerated() {
            let mutable = NSMutableAttributedString(attributedString: item)
            mutable.setFont(NSFont.systemFont(ofSize: pointSize))
            contents[i] = mutable
        }
        isDocumentEdited = true
    }
    
    
    func setFontColor(to color: NSColor) {
        for (i, item) in contents.enumerated() {
            let mutable = NSMutableAttributedString(attributedString: item)
            mutable.setFontColor(color)
            contents[i] = mutable
        }
        isDocumentEdited = true
    }
}
