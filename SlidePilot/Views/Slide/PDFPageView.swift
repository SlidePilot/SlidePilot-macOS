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
        var finishedReloading = false

        // After a given maximum reload time, a loading indicator should appear
        let maxReloadTime = 0.08
        DispatchQueue.global().asyncAfter(deadline: .now() + maxReloadTime) {
            if !finishedReloading {
                DispatchQueue.main.async {
                    print("start")
                    self.startLoadingIndicator()
                }
            }
        }

        // Reload page
        DispatchQueue.main.async {
            self.reloadBase()
            finishedReloading = true
            print("stop")
            self.stopLoadingIndicator()
        }
    }
    
    
    private func reloadBase() {
        self.imageScaling = .scaleAxesIndependently
        
        // Get current page
        guard pdfDocument != nil else { return }
        guard currentPage >= 0, currentPage < (pdfDocument?.pageCount ?? -1) else { return }
        guard let page = pdfDocument?.page(at: currentPage) else { return }
        
        // Crop page if needed
        let pageRect = getRectFor(mode: self.displayMode, pdfPage: page)
        page.setBounds(pageRect, for: .cropBox)
        
        // Create NSImage from page
        guard let pageData = page.dataRepresentation else { return }
        
        guard let pdfRep = NSPDFImageRep(data: pageData) else { return }
        let pdfImage = NSImage(size: pdfRep.size, flipped: false, drawingHandler: { (rect) -> Bool in
            guard let ctx = NSGraphicsContext.current?.cgContext else { return false }
            NSColor.white.set()
            ctx.fill(rect)

            pdfRep.draw(in: rect)

            return true
        })
        
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
    
    
    
    
    // MARK: - Loading Indicator
    
    var spinner: NSProgressIndicator?
    
    private func startLoadingIndicator() {
        if spinner != nil {
            stopLoadingIndicator()
        }
        
        spinner = NSProgressIndicator(frame: .zero)
        spinner?.translatesAutoresizingMaskIntoConstraints = false
        spinner?.style = .spinning
        spinner?.startAnimation(self)
    
        if let filter = CIFilter(name: "CIColorControls") {
            filter.setDefaults()
            filter.setValue(CGFloat(1.0), forKey: "inputBrightness")
            spinner?.contentFilters = [filter]
        }
        
        self.addSubview(spinner!)
        self.addConstraints([NSLayoutConstraint(item: spinner!, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: spinner!, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: spinner!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 20.0),
        NSLayoutConstraint(item: spinner!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 20.0)])
    }
    
    
    private func stopLoadingIndicator() {
        spinner?.removeFromSuperview()
        spinner = nil
    }
}

