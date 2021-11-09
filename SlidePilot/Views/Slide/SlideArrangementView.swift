//
//  SlideArrangementView.swift
//  SlidePilot
//
//  Created by Pascal Braband on 23.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa
import PDFKit


class SlideArrangementView: NSView {
    
    var trackingDelegate: SlideTrackingDelegate?
    
    var splitView: SplitView?
    var leftContainer: NSView?
    var rightContainer: NSView?
    
    var currentSlideView: SlideView?
    var nextSlideView: SlideView?
    var notesSlideView: SlideView?
    var notesEditor: NotesEditor?
    
    let padding: CGFloat = 30.0
    let distributionRatio: CGFloat = 0.6
    
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    
    
    // MARK: - UI Setup/Update
    
    func setup() {
        // Subscribe to page changes
        PageController.subscribe(target: self, action: #selector(pageDidChange(_:)))
        
        // Subscribe to document changes
        DocumentController.subscribeDidOpenDocument(target: self, action: #selector(documentDidChange(_:)))
        
        // Subscribe to display changes
        DisplayController.subscribeNotesPosition(target: self, action: #selector(notesPositionDidChange(_:)))
        DisplayController.subscribeDisplayNotes(target: self, action: #selector(displayNotesDidChange(_:)))
        DisplayController.subscribeDisplayCurrentSlide(target: self, action: #selector(displayCurrentSlideDidChange(_:)))
        DisplayController.subscribePreviewNextSlide(target: self, action: #selector(displayNextSlidePreviewDidChange(_:)))
        DisplayController.subscribeNotesMode(target: self, action: #selector(notesModeDidChange(_:)))
        DisplayController.subscribeDisplayDrawingTools(target: self, action: #selector(displayDrawingToolsDidChange(_:)))
        
        setupSplitView()
        
        // Setup View
        updateView()
    }
    
    
    private func updateView() {
        // Setup layout with/without next slide and with/without notes slide
        setupLayout(displayCurrent: DisplayController.isCurrentSlideDisplayed,
                    displayNext: DisplayController.isNextSlidePreviewDisplayed,
                    displayNotes: DisplayController.areNotesDisplayed,
                    displayDrawing: DisplayController.areDrawingToolsDisplayed,
                    notesMode: DisplayController.notesMode)
        
        // Setup notes position
        notesSlideView?.page?.setDisplayMode(DisplayController.notesPosition.displayModeForNotes())
        currentSlideView?.page?.setDisplayMode(DisplayController.notesPosition.displayModeForPresentation())
        nextSlideView?.page?.setDisplayMode(DisplayController.notesPosition.displayModeForPresentation())
        
        showSlide(at: PageController.currentPage)
    }
    
    
    
    
    // MARK: - UI Slides
    
    /** Updates slides and labels */
    private func updateSlides(for index: Int) {
        let currentSlideString = NSLocalizedString("Current Slide", comment: "Title for current slide.") + " \(index+1) / \(DocumentController.pageCount)"
        let notesSlideString = NSLocalizedString("Notes Slide", comment: "Title for notes slide.") + " \(index+1) / \(DocumentController.pageCount)"
        
        // Set current slide label
        currentSlideView?.label?.stringValue = currentSlideString
        
        // Set notes page
        if let notesPageView = notesSlideView?.page {
            notesPageView.setCurrentPage(index)
            notesSlideView?.label?.stringValue = notesSlideString
        }
        
        // Set notes editor title
        notesEditor?.label.stringValue = notesSlideString
        
        // Set next page
        if let nextPageView = nextSlideView?.page {
            if index + 1 < DocumentController.pageCount {
                nextPageView.setCurrentPage(index + 1)
                nextSlideView?.label?.stringValue = NSLocalizedString("Next Slide", comment: "Title for next slide")
            } else {
                // Show blank screen if last slide is currently displayed
                nextPageView.displayBlank()
                nextSlideView?.label?.stringValue = NSLocalizedString("Finished Presentation", comment: "Title for when no slide is left.")
            }
        }
    }
    
    
    func showSlide(at index: Int) {
        guard 0 <= index, index < DocumentController.pageCount  else { return }
        guard let page = currentSlideView?.page else { return }
        page.setCurrentPage(index)
        updateSlides(for: page.currentPage)
    }
    
    
    
    
    // MARK: - Control Handlers
    
    @objc private func pageDidChange(_ notification: Notification) {
        showSlide(at: PageController.currentPage)
    }
    
    
    @objc func documentDidChange(_ notification: Notification) {
        currentSlideView?.page.setDocument(DocumentController.document, mode: DisplayController.notesPosition.displayModeForPresentation())
        nextSlideView?.page.setDocument(DocumentController.document, mode: DisplayController.notesPosition.displayModeForPresentation())
        notesSlideView?.page.setDocument(DocumentController.document, mode: DisplayController.notesPosition.displayModeForNotes())
    }
    
    
    @objc func notesPositionDidChange(_ notification: Notification) {
        updateView()
    }
    
    
    @objc func displayNotesDidChange(_ notification: Notification) {
        updateView()
    }
    
    
    @objc func displayCurrentSlideDidChange(_ notification: Notification) {
        updateView()
    }
    
    
    @objc func displayNextSlidePreviewDidChange(_ notification: Notification) {
        updateView()
    }
    
    
    @objc func notesModeDidChange(_ notification: Notification) {
        updateView()
    }
    
    
    @objc func displayDrawingToolsDidChange(_ notification: Notification) {
        updateView()
    }
    
}



extension SlideArrangementView: SlideTrackingDelegate {
    
    func mouseMoved(to position: NSPoint, in sender: PDFPageView?) {
        trackingDelegate?.mouseMoved(to: position, in: sender)
    }
}
