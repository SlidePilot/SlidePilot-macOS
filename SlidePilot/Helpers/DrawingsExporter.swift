//
//  DrawingsExporter.swift
//  SlidePilot
//
//  Created by Pascal Braband on 22.02.22.
//  Copyright © 2022 Pascal Braband. All rights reserved.
//

import Foundation
import PDFKit

class DrawingsExporter {
    
    var document: PDFDocument!
    
    var drawings: [Int: Drawing]!
    
    /// Creates a new `DrawingsExporter` instance with the given parameters. Automatically creates a copy of the given `PDFDocument`.
    ///
    /// - Parameters:
    ///     - document: The `PDFDocument`, which should be stored.
    ///     - drawings: A dictionary of `Drawings`, which should be drawn on the documents pages.
    ///
    /// - Returns: A new optional instance of `DrawingsExporter`, initialized with the given parameters.
    public static func create(document: PDFDocument, drawings: [Int: Drawing]) -> DrawingsExporter? {
        guard let document = document.copy() as? PDFDocument else { return nil }
        return DrawingsExporter(document: document, drawings: drawings)
    }
    
    private init(document: PDFDocument, drawings: [Int: Drawing]) {
        // Check that
        self.document = document
        self.drawings = drawings
    }
    
    /// Writes the document to a given URL and draws the drawings on the corresponding pages.
    ///
    /// - Parameters:
    ///     - url: The `URL`, where the resulting PDF should be stored.
    ///     - progressHandler: This block gets called with progress updates to the write process. The block should take a `Double` as parameter, which is the progress from 0.0 to 1.0.
    ///
    /// - Returns: A `Bool` value indicating, whether writing the file was successful or not.
    @available(OSX 10.13, *)
    public func write(to url: URL, progressHandler: (Double) -> ()) -> Bool {
        // The overall workload is the pageCount, because every page needs to be worked on. +1 because document needs to be stored to disk as well
        let workload: Double = Double(document.pageCount + 1)
        
        for i in 0..<document.pageCount {
            // Notify progressHandler
            progressHandler(Double(i) / workload)
            guard let page = document.page(at: i) else { continue }
            
            // Reset crop box bounds to original page bounds
            page.setBounds(page.bounds(for: .mediaBox), for: .cropBox)
            
            // Add annotations to page
            // Get drawing for the current page
            guard let drawing = DocumentController.drawings[i] else { continue }
            
            let border = PDFBorder()
            border.lineWidth = 1.0
            
            // Add every line as an annotation
            for line in drawing.lines {
                let annotation = PDFAnnotation(bounds: page.bounds(for: .mediaBox), forType: .ink, withProperties: nil)
                annotation.color = line.color
                annotation.border = border
                
                let drawingFrame = page.bounds(for: .mediaBox)
                guard let drawingPath = line.getBezierPath(in: drawingFrame, drawingSection: drawingFrame) else { continue }
                annotation.add(drawingPath)
                
                page.addAnnotation(annotation)
            }
        }
        
        // Save document
        return document.write(to: url)
    }
}
