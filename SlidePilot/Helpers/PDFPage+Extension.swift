//
//  PDFPage+Extension.swift
//  SlidePilot
//
//  Created by Pascal Braband on 29.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa
import PDFKit

extension PDFPage {
    
    
    /**
     Extract a String from the PDF Page. Use this only for extracting text from the additional notes page
     */
    public func extractNotes() -> String {
        let pageRect = self.bounds(for: .cropBox)
        // Content rect ignores the note slides header
        let contentRect = NSRect(x: pageRect.minX, y: pageRect.minY, width: pageRect.width, height: pageRect.height*3/4)
        
        // Select everything in contentRect
        guard let selection = self.selection(for: contentRect) else { return "" }
        
        // Append each line in a string
        let lines = selection.selectionsByLine()
        var output = ""
        for line in lines {
            output += "\(line.string ?? "")\n"
        }
        
        return output.fixSpecialChars()
    }
    
    /**
     
     */
    private func getTranslationRatio(parent: CGRect, section: CGRect) -> CGSize {
        let translation = CGSize(
            width: parent.width / section.width,
            height: parent.height / section.height)
        
        return translation
    }
    
    func relativeBoundsInSection(for bounds: NSRect, displayMode: PDFPageView.DisplayMode) -> NSRect {
        // Full bounds of PDF page
        let pageBounds = PDFPageView.DisplayMode.full.getBounds(for: self)
        // Bounds of displayed section for PDF Page (regarding displayMode)
        let pageBoundsSection = displayMode.getBounds(for: self)
        
        // Calculate the relative bounds on PDF page
        let relativeBounds = NSRect(x: (bounds.origin.x - pageBounds.origin.x) / pageBounds.width,
                                    y: (bounds.origin.y - pageBounds.origin.y) / pageBounds.height,
                                    width: bounds.width / pageBounds.width,
                                    height: bounds.height / pageBounds.height)
        
        // Calculate the relative bounds in section of PDF Page with regards to displayMode
        let translation = getTranslationRatio(parent: pageBounds, section: pageBoundsSection)
        let relativeBoundsInSection = NSRect(x: (relativeBounds.minX - pageBoundsSection.minX / pageBounds.width) * translation.width,
                                             y: (relativeBounds.minY - pageBoundsSection.minY / pageBounds.height) * translation.height,
                                             width: relativeBounds.width * translation.width,
                                             height: relativeBounds.height * translation.height)
        
        return relativeBoundsInSection
    }
    
    func relativePointInSection(for point: NSPoint, displayMode: PDFPageView.DisplayMode) -> NSPoint {
        let relativeBounds = relativeBoundsInSection(
            for: NSRect(x: point.x, y: point.y, width: 0, height: 0),
            displayMode: displayMode)
        return NSPoint(x: relativeBounds.minX, y: relativeBounds.minY)
    }
    
    func boundsFromRelativeInSection(for bounds: NSRect, displayMode: PDFPageView.DisplayMode) -> NSRect {
        // Full bounds of PDF page
        let pageBounds = PDFPageView.DisplayMode.full.getBounds(for: self)
        // Bounds of displayed section for PDF Page (regarding displayMode)
        let pageBoundsSection = displayMode.getBounds(for: self)
        
        // Calculate the relative position on the full PDF page (from the section of the page)
        let translation = getTranslationRatio(parent: pageBounds, section: pageBoundsSection)
        let relativeBoundsOnPage = NSRect(
            x: bounds.minX / translation.width + pageBoundsSection.minX / pageBounds.width,
            y: bounds.minY / translation.height + pageBoundsSection.minY / pageBounds.height,
            width: bounds.width / translation.width,
            height: bounds.height / translation.height)
        
        // Calculate absolute bounds on full PDF Page
        let boundsOnPage = NSRect(
            x: relativeBoundsOnPage.minX * pageBounds.width + pageBounds.origin.x,
            y: relativeBoundsOnPage.minY * pageBounds.height + pageBounds.origin.y,
            width: relativeBoundsOnPage.width * pageBounds.width,
            height: relativeBoundsOnPage.height * pageBounds.height)
        
        return boundsOnPage
    }
    
    func pointFromRelativeInSection(for point: NSPoint, displayMode: PDFPageView.DisplayMode) -> NSPoint {
        let boundsOnPage = boundsFromRelativeInSection(
            for: NSRect(x: point.x, y: point.y, width: 0, height: 0),
            displayMode: displayMode)
        return NSPoint(x: boundsOnPage.minX, y: boundsOnPage.minY)
    }
}
