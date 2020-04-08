//
//  SlideArrangementView.swift
//  SlidePilot
//
//  Created by Pascal Braband on 23.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa
import PDFKit

protocol SlideArrangementDelegate: NSObject {
    func didSelectSlide(at index: Int)
    func didChangeDocument(_ document: PDFDocument?)
    func didChangeDisplayMode(_ mode: PDFPageView.DisplayMode)
}


class SlideArrangementView: NSView {
    
    var delegate: SlideTrackingDelegate?
    weak var slideDelegate: SlideArrangementDelegate?
    
    private var splitView: SplitView?
    private var leftContainer: NSView?
    private var rightContainer: NSView?
    
    var currentSlideView: SlideView?
    var nextSlideView: SlideView?
    var notesSlideView: SlideView?
    
    private let padding: CGFloat = 40.0
    private let distributionRatio: CGFloat = 0.6
    
    var pdfDocument: PDFDocument? {
        didSet {
            currentSlideView?.pdfDocument = self.pdfDocument
            nextSlideView?.pdfDocument = self.pdfDocument
            notesSlideView?.pdfDocument = self.pdfDocument
            slideDelegate?.didChangeDocument(self.pdfDocument)
            showSlide(at: 0, notifyDelegate: true)
        }
    }

    var displayNotes: Bool = false {
        didSet {
            updateView()
        }
    }
    
    
    var notesPosition: PDFPageView.NotesPosition = .none {
        didSet {
            updateView()
            slideDelegate?.didChangeDisplayMode(self.notesPosition.displayModeForPresentation())
        }
    }
    
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    
    
    // MARK: - UI Setup/Update
    
    private func setupView() {
        splitView = SplitView(frame: self.frame)
        splitView!.dividerStyle = .thin
        splitView!.isVertical = true
        splitView!.setDividerColor(NSColor(named: "DividerColor")!)
        
        splitView!.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(splitView!)
        self.addConstraints([NSLayoutConstraint(item: splitView!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
                             NSLayoutConstraint(item: splitView!, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0),
                             NSLayoutConstraint(item: splitView!, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0),
                             NSLayoutConstraint(item: splitView!, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0)])
        
        leftContainer = NSView(frame: .zero)
        splitView!.addSubview(leftContainer!)
        
        rightContainer = NSView(frame: .zero)
        splitView!.addSubview(rightContainer!)
        
        // Set min width for containers
        leftContainer!.addConstraint(NSLayoutConstraint(item: leftContainer!, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 300.0))
        rightContainer!.addConstraint(NSLayoutConstraint(item: rightContainer!, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 300.0))
        
        splitView!.adjustSubviews()
        updateView()
    }
    
    
    private func updateView() {
        // Cache current page
        let currentPage = currentSlideView?.page?.currentPage
        
        // Reset containers
        guard leftContainer != nil, rightContainer != nil else { return }
        leftContainer!.subviews.forEach({ $0.removeFromSuperview() })
        rightContainer!.subviews.forEach({ $0.removeFromSuperview() })
        
        // Setup layout with/without notes
        switch displayNotes {
            
        case true:
            setupSlidesLayoutWithNotes()
            
        case false:
            setupSlidesLayoutDefault()
        }
        
        // Setup notes position
        notesSlideView?.page?.displayMode = notesPosition.displayModeForNotes()
        currentSlideView?.page?.displayMode = notesPosition.displayModeForPresentation()
        nextSlideView?.page?.displayMode = notesPosition.displayModeForPresentation()
        
        showSlide(at: currentPage ?? 0, notifyDelegate: true)
    }
    
    
    private func setupSlidesLayoutDefault() {
        guard leftContainer != nil, rightContainer != nil else { return }
        
        // Left container: Setup current
        currentSlideView = SlideView(frame: .zero)
        currentSlideView!.delegate = self
        currentSlideView!.pdfDocument = self.pdfDocument
        currentSlideView!.translatesAutoresizingMaskIntoConstraints = false
        leftContainer?.addSubview(currentSlideView!)
        leftContainer?.addConstraints([
            NSLayoutConstraint(item: currentSlideView!, attribute: .centerX, relatedBy: .equal, toItem: leftContainer!, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: currentSlideView!, attribute: .height, relatedBy: .equal, toItem: currentSlideView!, attribute: .width, multiplier: 0.7, constant: 0.0),
            NSLayoutConstraint(item: currentSlideView!, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: leftContainer!, attribute: .top, multiplier: 1.0, constant: padding),
            NSLayoutConstraint(item: leftContainer!, attribute: .bottom, relatedBy: .greaterThanOrEqual, toItem: currentSlideView!, attribute: .bottom, multiplier: 1.0, constant: padding)])
        
        let currentCenterY = NSLayoutConstraint(item: currentSlideView!, attribute: .centerY, relatedBy: .equal, toItem: leftContainer!, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        currentCenterY.priority = NSLayoutConstraint.Priority(750.0)
        let currentWidth = NSLayoutConstraint(item: currentSlideView!, attribute: .width, relatedBy: .equal, toItem: leftContainer!, attribute: .width, multiplier: 0.9, constant: 0.0)
        currentWidth.priority = NSLayoutConstraint.Priority(260.0)
        leftContainer?.addConstraints([currentWidth, currentCenterY])
        
        
        // Right container: Setup next
        nextSlideView = SlideView(frame: .zero)
        nextSlideView!.pdfDocument = self.pdfDocument
        nextSlideView!.translatesAutoresizingMaskIntoConstraints = false
        rightContainer?.addSubview(nextSlideView!)
        rightContainer?.addConstraints([
            NSLayoutConstraint(item: nextSlideView!, attribute: .centerX, relatedBy: .equal, toItem: rightContainer!, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: nextSlideView!, attribute: .height, relatedBy: .equal, toItem: nextSlideView!, attribute: .width, multiplier: 0.7, constant: 0.0),
            NSLayoutConstraint(item: nextSlideView!, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: rightContainer!, attribute: .top, multiplier: 1.0, constant: padding),
            NSLayoutConstraint(item: rightContainer!, attribute: .bottom, relatedBy: .greaterThanOrEqual, toItem: nextSlideView!, attribute: .bottom, multiplier: 1.0, constant: padding)])
        
        let nextCenterY = NSLayoutConstraint(item: nextSlideView!, attribute: .centerY, relatedBy: .equal, toItem: rightContainer!, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        nextCenterY.priority = NSLayoutConstraint.Priority(750.0)
        let nextWidth = NSLayoutConstraint(item: nextSlideView!, attribute: .width, relatedBy: .equal, toItem: rightContainer!, attribute: .width, multiplier: 0.9, constant: 0.0)
        nextWidth.priority = NSLayoutConstraint.Priority(260.0)
        rightContainer?.addConstraints([nextWidth, nextCenterY])
        
        splitView?.setHoldingPriority(NSLayoutConstraint.Priority(270.0), forSubviewAt: 0)
        splitView?.setHoldingPriority(NSLayoutConstraint.Priority(270.0), forSubviewAt: 1)
    }
    
    
    private func setupSlidesLayoutWithNotes() {
        guard leftContainer != nil, rightContainer != nil else { return }
        
        // Left container: Setup notes
        notesSlideView = SlideView(frame: .zero)
        notesSlideView!.pdfDocument = self.pdfDocument
        notesSlideView!.translatesAutoresizingMaskIntoConstraints = false
        leftContainer?.addSubview(notesSlideView!)
        leftContainer?.addConstraints([
            NSLayoutConstraint(item: notesSlideView!, attribute: .centerX, relatedBy: .equal, toItem: leftContainer!, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: notesSlideView!, attribute: .height, relatedBy: .equal, toItem: notesSlideView!, attribute: .width, multiplier: 0.7, constant: 0.0),
            NSLayoutConstraint(item: notesSlideView!, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: leftContainer!, attribute: .top, multiplier: 1.0, constant: padding),
            NSLayoutConstraint(item: leftContainer!, attribute: .bottom, relatedBy: .greaterThanOrEqual, toItem: notesSlideView!, attribute: .bottom, multiplier: 1.0, constant: padding)])
        
        let notesCenterY = NSLayoutConstraint(item: notesSlideView!, attribute: .centerY, relatedBy: .equal, toItem: leftContainer!, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        notesCenterY.priority = NSLayoutConstraint.Priority(750.0)
        let notesWidth = NSLayoutConstraint(item: notesSlideView!, attribute: .width, relatedBy: .equal, toItem: leftContainer!, attribute: .width, multiplier: 0.9, constant: 0.0)
        notesWidth.priority = NSLayoutConstraint.Priority(260.0)
        leftContainer?.addConstraints([notesWidth, notesCenterY])
        
        
        // Right container: Setup current
        currentSlideView = SlideView(frame: .zero)
        currentSlideView!.delegate = self
        currentSlideView!.pdfDocument = self.pdfDocument
        currentSlideView!.translatesAutoresizingMaskIntoConstraints = false
        rightContainer?.addSubview(currentSlideView!)
        rightContainer?.addConstraints([
            NSLayoutConstraint(item: currentSlideView!, attribute: .centerX, relatedBy: .equal, toItem: rightContainer!, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: currentSlideView!, attribute: .height, relatedBy: .equal, toItem: currentSlideView!, attribute: .width, multiplier: 0.7, constant: 0.0),
            NSLayoutConstraint(item: currentSlideView!, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: rightContainer!, attribute: .top, multiplier: 1.0, constant: padding),
            NSLayoutConstraint(item: rightContainer!, attribute: .bottom, relatedBy: .greaterThanOrEqual, toItem: currentSlideView!, attribute: .bottom, multiplier: 1.0, constant: padding)])
        
        let currentCenterY = NSLayoutConstraint(item: currentSlideView!, attribute: .centerY, relatedBy: .equal, toItem: rightContainer!, attribute: .centerY, multiplier: 0.5, constant: 0.0)
        currentCenterY.priority = NSLayoutConstraint.Priority(750.0)
        let currentWidth = NSLayoutConstraint(item: currentSlideView!, attribute: .width, relatedBy: .equal, toItem: rightContainer!, attribute: .width, multiplier: 0.9, constant: 0.0)
        currentWidth.priority = NSLayoutConstraint.Priority(260.0)
        rightContainer?.addConstraints([currentWidth, currentCenterY])
        
        
        // Right container: Setup next
        nextSlideView = SlideView(frame: .zero)
        nextSlideView!.pdfDocument = self.pdfDocument
        nextSlideView!.translatesAutoresizingMaskIntoConstraints = false
        rightContainer?.addSubview(nextSlideView!)
        rightContainer?.addConstraints([
            NSLayoutConstraint(item: nextSlideView!, attribute: .centerX, relatedBy: .equal, toItem: rightContainer!, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: nextSlideView!, attribute: .height, relatedBy: .equal, toItem: nextSlideView!, attribute: .width, multiplier: 0.7, constant: 0.0),
            NSLayoutConstraint(item: nextSlideView!, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: rightContainer!, attribute: .top, multiplier: 1.0, constant: padding),
            NSLayoutConstraint(item: rightContainer!, attribute: .bottom, relatedBy: .greaterThanOrEqual, toItem: nextSlideView!, attribute: .bottom, multiplier: 1.0, constant: padding)])
        
        let nextCenterY = NSLayoutConstraint(item: nextSlideView!, attribute: .centerY, relatedBy: .equal, toItem: rightContainer!, attribute: .centerY, multiplier: 1.5, constant: 0.0)
        nextCenterY.priority = NSLayoutConstraint.Priority(750.0)
        let nextWidth = NSLayoutConstraint(item: nextSlideView!, attribute: .width, relatedBy: .equal, toItem: rightContainer!, attribute: .width, multiplier: 0.9, constant: 0.0)
        nextWidth.priority = NSLayoutConstraint.Priority(260.0)
        rightContainer?.addConstraints([nextWidth, nextCenterY])
        
        splitView?.setHoldingPriority(NSLayoutConstraint.Priority(270.0), forSubviewAt: 0)
        splitView?.setHoldingPriority(NSLayoutConstraint.Priority(270.0), forSubviewAt: 1)
    }
    
    
    
    
    // MARK: - UI Slides
    
    /** Updates slides and labels */
    private func updateSlides(for index: Int) {
        guard let currentPageView = currentSlideView?.page, currentSlideView?.pdfDocument != nil else { return }
        
        let currentSlideString = NSLocalizedString("Current Slide", comment: "Title for current slide") + " \(currentPageView.currentPage+1) / \(currentPageView.pdfDocument?.pageCount ?? 0)"
        
        // Set current slide label
        if displayNotes {
            currentSlideView?.label?.stringValue = NSLocalizedString("Current Slide", comment: "Title for current slide")
        } else {
            currentSlideView?.label?.stringValue = currentSlideString
        }
        
        // Set notes page
        if let notesPageView = notesSlideView?.page {
            notesPageView.currentPage = currentPageView.currentPage
            notesSlideView?.label?.stringValue = currentSlideString
        }
        
        // Set next page
        if let nextPageView = nextSlideView?.page {
            if currentPageView.currentPage + 1 < (currentPageView.pdfDocument?.pageCount ?? -1) {
                nextPageView.currentPage = currentPageView.currentPage + 1
                nextSlideView?.label?.stringValue = NSLocalizedString("Next Slide", comment: "Title for next slide")
            } else {
                // Show blank screen if last slide is currently displayed
                nextPageView.displayBlank()
                nextSlideView?.label?.stringValue = NSLocalizedString("Finished Presentation", comment: "Title for when no slide is left.")
            }
        }
    }
    
    
    func nextSlide() {
        guard let page = currentSlideView?.page else { return }
        showSlide(at: page.currentPage + 1, notifyDelegate: true)
        updateSlides(for: page.currentPage)
    }
    
    
    func previousSlide() {
        guard let page = currentSlideView?.page else { return }
        showSlide(at: page.currentPage - 1, notifyDelegate: true)
    }
    
    
    func showSlide(at index: Int, notifyDelegate: Bool) {
        guard 0 <= index, index < (pdfDocument?.pageCount ?? -1)  else { return }
        guard let page = currentSlideView?.page else { return }
        page.currentPage = index
        updateSlides(for: page.currentPage)
        
        if notifyDelegate {
            slideDelegate?.didSelectSlide(at: index)
        }
    }
    
}



extension SlideArrangementView: SlideTrackingDelegate {
    
    func mouseMoved(to position: NSPoint, in sender: PDFPageView?) {
        delegate?.mouseMoved(to: position, in: sender)
    }
}




extension SlideArrangementView: ThumbnailNavigationDelegate {
    
    func didSelectThumbnail(at index: Int) {
        showSlide(at: index, notifyDelegate: false)
    }
}
