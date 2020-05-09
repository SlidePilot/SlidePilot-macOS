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
    
    
    public static func writeToCurrentPage(_ text: String) -> Bool {
        guard let document = DocumentController.document,
            let currentPage = document.page(at: PageController.currentPage)
            else { return false }
        return write(text, to: currentPage)
    }
    
    
    /**
     Writes text to the notes annotation on a specified page and saves the PDF.
     
     - parameters:
        - text: The text to write to the notes annotation.
        - page: The page on which the text should be saved.
     
     - returns:
    `true` if writing and saving was successfull, `false` if not.
     */
    public static func write(_ text: String, to page: PDFPage) -> Bool {
        // Gather prequisites for saving
        guard let document = DocumentController.document else { return false }
        guard let documentFileURL = document.documentURL else { return false }
        
        // Compose notes string
        let notesString = notesAnnotationIdentifier + text
        
        // Update/Create annotation with notes string
        if let notesAnnotation = getNotesAnnotation(on: page) {
            // Write content to existing annotation
            notesAnnotation.contents = notesString
            notesAnnotation.modificationDate = Date()
        } else {
            // Create new annotation an write content
            let notesAnnotation = PDFAnnotation(bounds: NSRect(x: 0, y: 0, width: 25, height: 25))
            notesAnnotation.type = "Text"
            notesAnnotation.contents = notesString
            notesAnnotation.font = NSFont.init(name: "Helvetica", size: 12.0)
            notesAnnotation.color = NSColor(red: 1.0, green: 0.92, blue: 0.42, alpha: 1.0)
            notesAnnotation.alignment = .left
            notesAnnotation.fieldName = NSFullUserName()
            notesAnnotation.stampName = "Note"
            page.addAnnotation(notesAnnotation)
        }
        
        // Save updated PDF
        return document.write(to: documentFileURL)
    }
}
