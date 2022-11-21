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
    
    
    /// Extract a String from the PDF Page. Use this only for extracting text from the additional notes page
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
    
    /// Calculates the translation ratio between a parent frame and a subsection frame.
    ///
    /// - Parameters:
    ///     - parent: The parent frame.
    ///     - section: A section of the parent frame.
    ///
    /// - Returns: The translation ratio (vector) for translations between parent and child.
    private func getTranslationRatio(parent: CGRect, section: CGRect) -> CGSize {
        let translation = CGSize(
            width: parent.width / section.width,
            height: parent.height / section.height)
        
        return translation
    }
    
    /// Translates a rectangle, representing a frame inside the `PDFPage` bounds into a relative frame, in regards to the presented section of the page, which is determined by the `DisplayMode`.
    ///
    /// - Parameters:
    ///     - bounds: The absolute frame inside the `PDFPage` bounds.
    ///     - displayMode: The `DisplayMode` which determines the section, in which the relative frame should be translated.
    ///
    /// - Returns: An `NSRect` which represents the given frame as a relative frame in the desired section of the page.
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
    
    /// Translates a coordinate, representing a point inside the `PDFPage` bounds into a relative coordinate, in regards to the presented section of the page, which is determined by the `DisplayMode`.
    ///
    /// - Parameters:
    ///     - point: The absolute coordinate inside the `PDFPage` bounds.
    ///     - displayMode: The `DisplayMode` which determines the section, in which the relative coordinates should be translated.
    ///
    /// - Returns: An `NSPoint` which represents the given point as relative coordinates in the desired section of the page.
    func relativePointInSection(for point: NSPoint, displayMode: PDFPageView.DisplayMode) -> NSPoint {
        let relativeBounds = relativeBoundsInSection(
            for: NSRect(x: point.x, y: point.y, width: 0, height: 0),
            displayMode: displayMode)
        return NSPoint(x: relativeBounds.minX, y: relativeBounds.minY)
    }
    
    /// Translates a rectangle, representing a relative frame inside a section of the `PDFPage`, into an absolute frame on the full page, in regards to the presented section of the page, which is determined by the `DisplayMode`.
    ///
    /// - Parameters:
    ///     - bounds: The relative frame inside the section of the `PDFPage`.
    ///     - displayMode: The `DisplayMode` which determines the section, from which the relative frame should be translated.
    ///
    /// - Returns: An `NSRect` which represents the given frame as an absolute frame on the full page.
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
    
    /// Translates a coordinate, representing a relative point inside a section of the `PDFPage`, into an absolute coordinate on the full page, in regards to the presented section of the page, which is determined by the `DisplayMode`.
    ///
    /// - Parameters:
    ///     - point: The relative coordinate inside the section of the `PDFPage`.
    ///     - displayMode: The `DisplayMode` which determines the section, from which the relative point should be translated.
    ///
    /// - Returns: An `NSPoint` which represents the given point as an absolute coordinate on the full page.
    func pointFromRelativeInSection(for point: NSPoint, displayMode: PDFPageView.DisplayMode) -> NSPoint {
        let boundsOnPage = boundsFromRelativeInSection(
            for: NSRect(x: point.x, y: point.y, width: 0, height: 0),
            displayMode: displayMode)
        return NSPoint(x: boundsOnPage.minX, y: boundsOnPage.minY)
    }
}

// TODO:
//   - Document code
//   - Document functions
//   - Test functions
//   - Drawing refactor
