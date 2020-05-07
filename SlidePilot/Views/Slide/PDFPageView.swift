//
//  PDFPageView.swift
//  SlidePilot
//
//  Created by Pascal Braband on 23.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa
import PDFKit


class PDFPageView: NSImageView {
    
    
    enum DisplayMode {
        case full, leftHalf, rightHalf, topHalf, bottomHalf
        
        static func displayModeForNotes(with position: NotesPosition) -> DisplayMode {
            return position.displayModeForNotes()
        }
        
        static func displayModeForPresentation(with position: NotesPosition) -> DisplayMode {
            return position.displayModeForPresentation()
        }
    }
    
    
    enum NotesPosition {
        case none, right, left, bottom, top
        
        func displayModeForNotes() -> DisplayMode {
            switch self {
            case .none:
                return .full
            case .right:
                return .rightHalf
            case .left:
                return .leftHalf
            case .bottom:
                return .bottomHalf
            case .top:
                return .topHalf
            }
        }
        
        func displayModeForPresentation() -> DisplayMode {
            switch self {
            case .none:
                return .full
            case .right:
                return .leftHalf
            case .left:
                return .rightHalf
            case .bottom:
                return .topHalf
            case .top:
                return .bottomHalf
            }
        }
    }
    
    
    private(set) var pdfDocument: PDFDocument?
    private(set) var displayMode: DisplayMode = .full
    private(set) var currentPage: Int = 0
    
    
    public func setDocument(_ document: PDFDocument?, mode displayMode: DisplayMode = .full, at currentPage: Int = 0) {
        self.pdfDocument = document
        self.displayMode = displayMode
        self.currentPage = currentPage
        RenderCache.shared.document = document
        reload()
    }
    
    
    public func setDisplayMode(_ displayMode: DisplayMode) {
        self.displayMode = displayMode
        reload()
    }
    
    
    public func setCurrentPage(_ currentPage: Int) {
        self.currentPage = currentPage
        reload()
    }
    
    
    public func pageForward() {
        guard currentPage + 1 < (pdfDocument?.pageCount ?? -1) else { return }
        currentPage = currentPage + 1
        reload()
    }
    
    
    public func pageBackward() {
        guard currentPage - 1 >= 0 else { return }
        currentPage = currentPage - 1
        reload()
    }
    
    
    private func reload() {
        // Get current page
        guard pdfDocument != nil else { return }
        guard currentPage >= 0, currentPage < (pdfDocument?.pageCount ?? -1) else { return }
        
        // Create NSImage from page
        guard let pdfImage = RenderCache.shared.getPage(at: currentPage, for: pdfDocument!, mode: self.displayMode, priority: .fast) else { return }
        
        // Display image
        self.imageScaling = .scaleProportionallyUpOrDown
        self.image = pdfImage
        
        // Update cursor rects
        self.window?.invalidateCursorRects(for: self)
    }
    
    
    override func resetCursorRects() {
        super.resetCursorRects()
        
        // Add cursor rects for annotation
        addAnnotationCursorRects()
    }
    
    
    /** Adds cursor rect for where clickable annotations are. */
    private func addAnnotationCursorRects() {
        // Extract annotations
        guard let page = pdfDocument?.page(at: currentPage) else { return }
        
        // Add cursor rects for each annotation
        for annotation in page.annotations {
            // Only add cursor rect for link annotations
            guard annotation.type == "Link" else { continue }
            
            let annotationBounds = annotation.bounds
            let pageBounds = page.bounds(for: .cropBox)
            
            // Calculate relative bounds on PDF page
            let relativeBounds = NSRect(x: annotationBounds.origin.x / pageBounds.width,
                                        y: annotationBounds.origin.y / pageBounds.height,
                                        width: annotationBounds.width / pageBounds.width,
                                        height: annotationBounds.height / pageBounds.height)
            
            // Translate relative annotations bounds to PDF image bounds
            let imageFrame = imageRect()
            let annotationBoundsInImage = NSRect(x: relativeBounds.origin.x * imageFrame.width,
                                                 y: relativeBounds.origin.y * imageFrame.height,
                                                 width: relativeBounds.width * imageFrame.width,
                                                 height: relativeBounds.height * imageFrame.height)
            
            // Translate the annotation bounds position to self view frame
            let annotationBoundsInView = NSRect(x: annotationBoundsInImage.origin.x + imageFrame.origin.x,
                                                y: annotationBoundsInImage.origin.y + imageFrame.origin.y,
                                                width: annotationBoundsInImage.width,
                                                height: annotationBoundsInImage.height)
            
            addCursorRect(annotationBoundsInView, cursor: .pointingHand)
        }
    }
    
    
    override func mouseDown(with event: NSEvent) {
        // Calculate the point in relativity to this views origin
        guard let pointInView = self.window?.contentView?.convert(event.locationInWindow, to: self) else { return }
        
        // Calculate the absolute point on the displayed PDF image
        let imageFrame = imageRect()
        let pointInImage = NSPoint(x: pointInView.x - imageFrame.origin.x, y: pointInView.y - imageFrame.origin.y)
        
        // Calculate the relative point on the displayed PDF image (relative to its size)
        let relativePointInImage = NSPoint(x: pointInImage.x / imageFrame.width , y: pointInImage.y / imageFrame.height)
        
        // Calculate click point relative to PDF page bounds
        guard let page = pdfDocument?.page(at: currentPage) else { return }
        let pageBounds = page.bounds(for: .cropBox)
        let pointOnPage = NSPoint(x: relativePointInImage.x * pageBounds.width, y: relativePointInImage.y * pageBounds.height)
        
        // Get annotation for click position
        let annotation = pdfDocument?.page(at: currentPage)?.annotation(at: pointOnPage)
        
        
        // Handle clicking on annotation
        
        // Go to document page
        if let goToAction = annotation?.action as? PDFActionGoTo {
            guard let destPage = goToAction.destination.page else { return }
            guard let destPageIndex = pdfDocument?.index(for: destPage) else { return }
            PageController.selectPage(at: destPageIndex, sender: self)
        }
        
        // Open web page
        else if let urlAction = annotation?.action as? PDFActionURL {
            guard let url = urlAction.url else { return }
            // Open url in browser
            if #available(OSX 10.15, *) {
                let openConfig = NSWorkspace.OpenConfiguration()
                openConfig.addsToRecentItems = true
                NSWorkspace.shared.open(url, configuration: openConfig, completionHandler: nil)
            } else {
                NSWorkspace.shared.open(url)
            }
        }
    }
    
    
    private func getRectFor(mode: DisplayMode, pdfPage: PDFPage) -> CGRect {
        switch mode {
        case .full:
            return pdfPage.bounds(for: .mediaBox)
        case .leftHalf:
            return CGRect(x: 0, y: 0, width: pdfPage.bounds(for: .mediaBox).width/2, height: pdfPage.bounds(for: .mediaBox).height)
        case .rightHalf:
            return CGRect(x: pdfPage.bounds(for: .mediaBox).width/2, y: 0, width: pdfPage.bounds(for: .mediaBox).width/2, height: pdfPage.bounds(for: .mediaBox).height)
        case .topHalf:
            return CGRect(x: 0, y: pdfPage.bounds(for: .mediaBox).height/2, width: pdfPage.bounds(for: .mediaBox).width, height: pdfPage.bounds(for: .mediaBox).height/2)
        case .bottomHalf:
            return CGRect(x: 0, y: 0, width: pdfPage.bounds(for: .mediaBox).width, height: pdfPage.bounds(for: .mediaBox).height/2)
        }
    }
    
    
    
    
    // MARK: - Alternative Display and Cover
    
    public func displayBlank() {
        self.image = NSColor.black.image(of: (pdfDocument?.page(at: 0)?.bounds(for: .cropBox).size ?? NSSize(width: 1.0, height: 1.0)))
    }
    
    
    private var coverView: NSView?
    
    private func addCover() {
        uncover()
        self.coverView = NSView(frame: .zero)
        self.coverView?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(coverView!)
        self.addConstraints([NSLayoutConstraint(item: coverView!, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: coverView!, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: coverView!, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: coverView!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0)])
    }
    
    
    public var isCoveredWhite: Bool = false
    
    /** Covers the view with a white screen */
    public func coverWhite() {
        addCover()
        self.coverView?.wantsLayer = true
        self.coverView?.layer?.backgroundColor = NSColor.white.cgColor
        isCoveredWhite = true
    }
    
    
    public var isCoveredBlack: Bool = false
    
    /** Covers the view with a black screen */
    public func coverBlack() {
        addCover()
        self.coverView?.wantsLayer = true
        self.coverView?.layer?.backgroundColor = NSColor.black.cgColor
        isCoveredBlack = true
    }
    
    
    public func uncover() {
        coverView?.removeFromSuperview()
        coverView = nil
        isCoveredWhite = false
        isCoveredBlack = false
    }
}

