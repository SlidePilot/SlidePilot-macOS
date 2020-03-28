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
    
    
    public var pdfDocument: PDFDocument? {
        didSet {
            currentPage = 0
        }
    }
    
    
    public var displayMode: DisplayMode = .full {
        didSet {
            reload()
        }
    }
    
    
    public var currentPage: Int = 0 {
        didSet {
            reload()
        }
    }
    
    
    public func pageForward() {
        guard currentPage + 1 < (pdfDocument?.pageCount ?? -1) else { return }
        currentPage = currentPage + 1
    }
    
    
    public func pageBackward() {
        guard currentPage - 1 >= 0 else { return }
        currentPage = currentPage - 1
    }
    
    
    private func reload() {
        self.imageScaling = .scaleAxesIndependently
        
        // Get current page
        guard pdfDocument != nil else { return }
        guard currentPage >= 0, currentPage < (pdfDocument?.pageCount ?? -1) else { return }
        guard let page = pdfDocument?.page(at: currentPage) else { return }
        
//        let border = PDFAnnotation(bounds: page.bounds(for: .cropBox), forType: .square, withProperties: nil)
//        border.border = PDFBorder()
//        border.border?.style = .solid
//        border.border?.lineWidth = 0.5
//        border.color = NSColor.textColor
//        page.addAnnotation(border)
        
        // Crop page if needed
        let pageRect = getRectFor(mode: self.displayMode, pdfPage: page)
        page.setBounds(pageRect, for: .cropBox)
        
        // Create NSImage from page
        guard let pageData = page.dataRepresentation else { return }
        guard let pdfImage = NSImage(data: pageData) else { return }
        
        // Display image
        self.image = pdfImage
        self.imageScaling = .scaleProportionallyUpOrDown
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
        self.image = NSColor(named: "DefaultColor")!.image(of: (pdfDocument?.page(at: 0)?.bounds(for: .cropBox).size ?? NSSize(width: 1.0, height: 1.0)))
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

