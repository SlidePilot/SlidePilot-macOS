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
    var isDocumentEdited: Bool
    
    
    /**
     Initializes the document with the contents of the file at the given URL.
     
     - returns:
     `nil` if loading the file failed.
     */
    init?(contentsOf fileURL: URL) {
        self.url = fileURL
        self.isDocumentEdited = false
        super.init()
        if !load(fileURL: fileURL) {
            return nil
        }
    }
    
    
    override init() {
        self.url = nil
        self.isDocumentEdited = false
        super.init()
    }
    
    
    /**
     Sets the notes for a specified page.
     */
    func set(notes: NSAttributedString, on pageIndex: Int) {
        contents[pageIndex] = notes
        
        // New unsaved changes
        isDocumentEdited = true
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
            output.append(NSAttributedString(string: "SLIDEPILOT-NOTES-PAGE-SEPARATOR#-Page-\(i+1)\n"))
            output.append(pageContent)
        }
        
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
}
