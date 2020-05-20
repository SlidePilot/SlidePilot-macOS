//
//  NotesAnnotation.swift
//  SlidePilot
//
//  Created by Pascal Braband on 09.05.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Foundation
import PDFKit

class NotesAnnotation {
    
    private static let notesAnnotationIdentifier = "#SLIDEPILOT-NOTES#\n"
    private static let notesAnnotationPageSeparator = "#SLIDEPILOT-NOTES-PAGE-SEPARATOR#"
    
    
    
    
    // MARK: - Read/Write
    
    /**
     - returns
     The text from the notes annotation on the current page. Returns nil if no notes annotation on current page.
     */
    public static func getNotesOnCurrentPage() -> String? {
        guard let notesAnnotationString = getNotesAnnotationOnCurrentPage()?.contents else { return nil }
        
        // Remove notesAnnotationIdentifier and then return string
        return String(notesAnnotationString.dropFirst(notesAnnotationIdentifier.count))
    }

    
    /**
     - returns:
     The notes annoation from the current page. Returns nil if no notes annotation on current page.
     */
    public static func getNotesAnnotationOnCurrentPage() -> PDFAnnotation? {
        guard let document = DocumentController.document,
            let currentPage = document.page(at: PageController.currentPage)
            else { return nil }
        return getNotesAnnotation(on: currentPage)
    }
    
    
    /**
     - returns:
     The text from the notes annotation on the given page. Returns nil if no notes annotation on current page.
    */
    public static func getNotesText(on page: PDFPage) -> String? {
        guard let notesAnnotationString = getNotesAnnotation(on: page)?.contents else { return nil }
        
        // Remove notesAnnotationIdentifier and then return string
        return String(notesAnnotationString.dropFirst(notesAnnotationIdentifier.count))
    }
    
    
    /**
     - returns:
     The notes annoation from the given page. Returns nil if no notes annotation on given page.
     */
    public static func getNotesAnnotation(on page: PDFPage) -> PDFAnnotation? {
        let annotations = page.annotations
        let notesAnnotation = annotations.first(where: { (annotation) in
            guard annotation.type == "Text" else { return false }
            guard let annotationContents = annotation.contents else { return false }
            return annotationContents.hasPrefix(notesAnnotationIdentifier)
        })
        return notesAnnotation
    }
    
    
    /**
     Writes text to the notes annotation on the current page and saves the PDF.
      
      - parameters:
         - text: The text to write to the notes annotation.
      
      - returns:
     `true` if writing and saving was successfull, `false` if not.
     */
    public static func writeToCurrentPage(_ text: String) -> Bool {
        guard let document = DocumentController.document,
            let currentPage = document.page(at: PageController.currentPage)
            else { return false }
        return write(text, to: currentPage)
    }
    
    
    /**
     Writes text to the notes annotation on the specified page.
     
     *Important:* The document is not saved to the disk, only the document in the application is changed.
     
     - parameters:
        - text: The text to write to the notes annotation.
        - page: The page on which the text should be saved.
     
     - returns:
    `true` if writing and saving was successfull, `false` if not.
     */
    public static func write(_ text: String, to page: PDFPage) -> Bool {
        // Compose notes string
        let notesString = notesAnnotationIdentifier + text
        
        // Update annotation with notes string
        if let notesAnnotation = getNotesAnnotation(on: page) {
            // Write content to existing annotation
            notesAnnotation.contents = notesString
            notesAnnotation.modificationDate = Date()
        }
        
        // Create annotation with notes string, but only if given text was not empty
        else if text != "" {
            // Create new annotation an write content
            let notesAnnotation = PDFAnnotation(bounds: NSRect(x: 0, y: 0, width: 25, height: 25))
            notesAnnotation.type = "Text"
            notesAnnotation.contents = notesString
            notesAnnotation.font = NSFont.init(name: "Helvetica", size: 12.0)
            notesAnnotation.color = NSColor(red: 1.0, green: 0.92, blue: 0.42, alpha: 1.0)
            notesAnnotation.alignment = .left
            notesAnnotation.fieldName = NSFullUserName()
            notesAnnotation.stampName = "Note"
            notesAnnotation.shouldPrint = false
            page.addAnnotation(notesAnnotation)
        }
        return true
    }
    
    
    
    
    // MARK: - Import/Export
    
    /**
     Gathers the text from all annotations on that page and puts them in the notes annotation.
     This will override the existing content in the notes annotation on that page.
     
     - parameters:
        - page: The `PDFPage` on which the import should be done.
     */
    public static func importNotesFromAnnotation(page: PDFPage) -> Bool {
        var annotationsText = ""
        
        // Iterate over all annotations and put them in one string
        for annotation in page.annotations {
            if annotation.type == "Text" {
                guard let annotationContent = annotation.contents else { continue }
                // Don't import annotation content from own notes annotation
                guard !annotationContent.hasPrefix(notesAnnotationIdentifier) else { continue }
                annotationsText += annotationContent + "\n"
            }
        }
        
        // Write the gathered text into the notes annotation
        return write(annotationsText, to: page)
    }
    
    
    /**
     Gathers the text from all annotations on the current page and puts them in the notes annotation.
     This will override the existing content in the notes annotation on that page.
     */
    public static func importNotesFromAnnotationForCurrentPage() -> Bool {
        guard let document = DocumentController.document,
            let currentPage = document.page(at: PageController.currentPage)
            else { return false }
        
        return importNotesFromAnnotation(page: currentPage)
    }
    
    
    /**
     Imports the text from annotations into the notes annotation for every page in the document.
     */
    public static func importNotesFromAnnotationForDocument() -> Bool {
        guard let document = DocumentController.document else { return false }
        
        // Go over every page in document and import notes
        var didSucceed = true
        for index in 0...document.pageCount-1 {
            guard let page = document.page(at: index) else { continue }
            didSucceed = didSucceed && importNotesFromAnnotation(page: page)
        }
        return didSucceed
    }
    
    
    /**
     Writes the content of all notes annotations to a `.txt` file.
     
     - parameters:
        - file: The `URL` file path, where the file should be stored.
     
     - returns:
    `true` if export and saving was successfull, `false` otherwise.
     */
    public static func exportNotes(to file: URL) -> Bool {
        guard let document = DocumentController.document else { return false }
        
        // Compose export string
        var exportString = ""
        
        // Go over every page in document and gather the content of notes annotations
        for index in 0...document.pageCount-1 {
            // Add page separator
            exportString += notesAnnotationPageSeparator + "\n"
            
            guard let page = document.page(at: index) else { continue }
            if let notesText = getNotesText(on: page) {
                // Append notes to export
                exportString += notesText + "\n"
            }
        }
        
        // Save to file
        do {
            try exportString.write(to: file, atomically: true, encoding: .utf8)
            return true
        } catch let error {
            print(error)
            return false
        }
    }
    
    /**
     Imports the content a notes file to all corresponding notes annotations.
     
     - parameters:
        - file: The `URL` file path, where the notes file is located.
     
     - returns:
    `true` if import was successfull, `false` otherwise.
     */
    public static func importNotes(from file: URL) -> Bool {
        guard let document = DocumentController.document else { return false }
        
        do {
            // Read notes file
            let importString = try String(contentsOf: file)
            
            // Separate importString with page separator. Drop first to remove empty string
            var notesPerPage = importString.components(separatedBy: notesAnnotationPageSeparator + "\n")
            notesPerPage.removeFirst(1)
            
            // Ensure that there are enough notes to fill document
            guard notesPerPage.count == document.pageCount else { return false }
            
            var didSucceed = true
            for index in 0...document.pageCount-1 {
                // Add each component to the correct page notes annotation
                guard let page = document.page(at: index) else { continue }
                
                didSucceed = didSucceed && write(notesPerPage[index], to: page)
            }
            
            return didSucceed
        } catch let error {
            print(error)
            return false
        }
        
    }
}
