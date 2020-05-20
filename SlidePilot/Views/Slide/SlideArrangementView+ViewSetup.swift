//
//  SlideArrangementView+ViewSetup.swift
//  SlidePilot
//
//  Created by Pascal Braband on 02.05.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

// This extension contains all the UI code for the different view setups
extension SlideArrangementView {
    
    func setupLayout(displayNext: Bool, displayNotes: Bool, notesMode: DisplayController.NotesMode) {
        willSwitchLayout()
        
        clearView()
        if displayNext == false, displayNotes == false {
            setupSlidesLayoutCurrent()
        } else if displayNext == true, displayNotes == false {
            setupSlidesLayoutCurrentNext()
        } else if displayNext == true, displayNotes == true, notesMode == .split {
            setupSlidesLayoutCurrentNextNotes()
        } else if displayNext == false, displayNotes == true, notesMode == .split {
            setupSlidesLayoutCurrentNotes()
        } else if displayNext == true, displayNotes == true, notesMode == .text {
            setupSlidesLayoutCurrentNextNotesText()
        } else if displayNext == false, displayNotes == true, notesMode == .text {
            setupSlidesLayoutCurrentNotesText()
        }
    }
    
    
    private func willSwitchLayout() {
        // Switching layout may remove subviews
        // Put all actions that need to be done before that in here
    }
    
    
    private func clearView() {
        // Remove all subviews, but keep split view
        self.subviews.forEach({
            if $0 != splitView {
                $0.removeFromSuperview()
            }
        })
        
        // Remove all subviews from split view containers
        leftContainer!.subviews.forEach({ $0.removeFromSuperview() })
        rightContainer!.subviews.forEach({ $0.removeFromSuperview() })
        
        // Remove references to views
        notesTextView = nil
    }
    
    
    func setupSplitView() {
        splitView = SplitView(frame: self.frame)
        splitView!.dividerStyle = .thin
        splitView!.isVertical = true
        splitView!.setDividerColor(DividerColor)
        
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
    }
    
    
    private func setupSlidesLayoutCurrent() {
        splitView?.isHidden = true
        
        currentSlideView = SlideView(frame: .zero)
        currentSlideView!.delegate = self
        currentSlideView!.page.setDocument(DocumentController.document)
        currentSlideView!.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(currentSlideView!)
        self.addConstraints([
            NSLayoutConstraint(item: currentSlideView!, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: currentSlideView!, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0.9, constant: 0.0),
            NSLayoutConstraint(item: currentSlideView!, attribute: .left, relatedBy: .greaterThanOrEqual, toItem: self, attribute: .left, multiplier: 1.0, constant: padding),
            NSLayoutConstraint(item: currentSlideView!, attribute: .right, relatedBy: .greaterThanOrEqual, toItem: self, attribute: .right, multiplier: 1.0, constant: -padding),
            NSLayoutConstraint(item: currentSlideView!, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0)])
    }
    
    
    private func setupSlidesLayoutCurrentNext() {
        guard splitView != nil, leftContainer != nil, rightContainer != nil else { return }
        splitView?.isHidden = false
        
        // Left container: Setup current
        setupCurrentSlideView(in: leftContainer!)
        
        // Right container: Setup next
        setupNextSlideView(in: rightContainer!)
        
        splitView?.setHoldingPriority(NSLayoutConstraint.Priority(270.0), forSubviewAt: 0)
        splitView?.setHoldingPriority(NSLayoutConstraint.Priority(270.0), forSubviewAt: 1)
    }
    
    
    private func setupSlidesLayoutCurrentNotes() {
        guard splitView != nil, leftContainer != nil, rightContainer != nil else { return }
        splitView?.isHidden = false
        
        // Left container: Setup notes
        setupNotesSlideView(in: leftContainer!)
        
        
        // Right container: Setup current
        setupCurrentSlideView(in: rightContainer!)
        
        splitView?.setHoldingPriority(NSLayoutConstraint.Priority(270.0), forSubviewAt: 0)
        splitView?.setHoldingPriority(NSLayoutConstraint.Priority(270.0), forSubviewAt: 1)
    }
    
    
    private func setupSlidesLayoutCurrentNotesText() {
        guard splitView != nil, leftContainer != nil, rightContainer != nil else { return }
        splitView?.isHidden = false
        
        // Left container: Setup notes
        setupNotesTextView(in: leftContainer!)
        
        // Right container: Setup current
        setupCurrentSlideView(in: rightContainer!)
        
        splitView?.setHoldingPriority(NSLayoutConstraint.Priority(270.0), forSubviewAt: 0)
        splitView?.setHoldingPriority(NSLayoutConstraint.Priority(270.0), forSubviewAt: 1)
    }
    
    
    private func setupSlidesLayoutCurrentNextNotes() {
        guard splitView != nil, leftContainer != nil, rightContainer != nil else { return }
        splitView?.isHidden = false
        
        // Left container: Setup notes
        setupNotesSlideView(in: leftContainer!)
        
        // Right container: Setup current
        setupCurrentSlideView(in: rightContainer!, centerYMultiplier: 0.5)
        
        // Right container: Setup next
        setupNextSlideView(in: rightContainer!, centerYMultiplier: 1.5)
        
        splitView?.setHoldingPriority(NSLayoutConstraint.Priority(270.0), forSubviewAt: 0)
        splitView?.setHoldingPriority(NSLayoutConstraint.Priority(270.0), forSubviewAt: 1)
    }
    
    
    func setupSlidesLayoutCurrentNextNotesText() {
        guard splitView != nil, leftContainer != nil, rightContainer != nil else { return }
        splitView?.isHidden = false
        
        // Left container: Setup notes
        setupNotesTextView(in: leftContainer!)
        
        // Right container: Setup current
        setupCurrentSlideView(in: rightContainer!, centerYMultiplier: 0.5)
        
        // Right container: Setup next
        setupNextSlideView(in: rightContainer!, centerYMultiplier: 1.5)
        
        splitView?.setHoldingPriority(NSLayoutConstraint.Priority(270.0), forSubviewAt: 0)
        splitView?.setHoldingPriority(NSLayoutConstraint.Priority(270.0), forSubviewAt: 1)
    }
    
    
    func setupCurrentSlideView(in container: NSView, centerYMultiplier: CGFloat = 1.0) {
        currentSlideView = SlideView(frame: .zero)
        currentSlideView!.delegate = self
        currentSlideView!.page.setDocument(DocumentController.document)
        currentSlideView!.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(currentSlideView!)
        container.addConstraints([
            NSLayoutConstraint(item: currentSlideView!, attribute: .centerX, relatedBy: .equal, toItem: container, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: currentSlideView!, attribute: .height, relatedBy: .equal, toItem: currentSlideView!, attribute: .width, multiplier: 0.7, constant: 0.0),
            NSLayoutConstraint(item: currentSlideView!, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: container, attribute: .top, multiplier: 1.0, constant: padding),
            NSLayoutConstraint(item: container, attribute: .bottom, relatedBy: .greaterThanOrEqual, toItem: currentSlideView!, attribute: .bottom, multiplier: 1.0, constant: padding)])
        
        let currentCenterY = NSLayoutConstraint(item: currentSlideView!, attribute: .centerY, relatedBy: .equal, toItem: container, attribute: .centerY, multiplier: centerYMultiplier, constant: 0.0)
        currentCenterY.priority = NSLayoutConstraint.Priority(750.0)
        let currentWidth = NSLayoutConstraint(item: currentSlideView!, attribute: .width, relatedBy: .equal, toItem: container, attribute: .width, multiplier: 0.9, constant: 0.0)
        currentWidth.priority = NSLayoutConstraint.Priority(260.0)
        container.addConstraints([currentWidth, currentCenterY])
    }
    
    
    func setupNextSlideView(in container: NSView, centerYMultiplier: CGFloat = 1.0) {
        nextSlideView = SlideView(frame: .zero)
        nextSlideView!.page.setDocument(DocumentController.document)
        nextSlideView!.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(nextSlideView!)
        container.addConstraints([
            NSLayoutConstraint(item: nextSlideView!, attribute: .centerX, relatedBy: .equal, toItem: container, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: nextSlideView!, attribute: .height, relatedBy: .equal, toItem: nextSlideView!, attribute: .width, multiplier: 0.7, constant: 0.0),
            NSLayoutConstraint(item: nextSlideView!, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: container, attribute: .top, multiplier: 1.0, constant: padding),
            NSLayoutConstraint(item: container, attribute: .bottom, relatedBy: .greaterThanOrEqual, toItem: nextSlideView!, attribute: .bottom, multiplier: 1.0, constant: padding)])
        
        let nextCenterY = NSLayoutConstraint(item: nextSlideView!, attribute: .centerY, relatedBy: .equal, toItem: container, attribute: .centerY, multiplier: centerYMultiplier, constant: 0.0)
        nextCenterY.priority = NSLayoutConstraint.Priority(750.0)
        let nextWidth = NSLayoutConstraint(item: nextSlideView!, attribute: .width, relatedBy: .equal, toItem: container, attribute: .width, multiplier: 0.9, constant: 0.0)
        nextWidth.priority = NSLayoutConstraint.Priority(260.0)
        container.addConstraints([nextWidth, nextCenterY])
    }
    
    
    func setupNotesSlideView(in container: NSView) {
        notesSlideView = SlideView(frame: .zero)
        notesSlideView!.page.setDocument(DocumentController.document)
        notesSlideView!.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(notesSlideView!)
        container.addConstraints([
            NSLayoutConstraint(item: notesSlideView!, attribute: .centerX, relatedBy: .equal, toItem: container, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: notesSlideView!, attribute: .height, relatedBy: .equal, toItem: notesSlideView!, attribute: .width, multiplier: 0.7, constant: 0.0),
            NSLayoutConstraint(item: notesSlideView!, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: container, attribute: .top, multiplier: 1.0, constant: padding),
            NSLayoutConstraint(item: container, attribute: .bottom, relatedBy: .greaterThanOrEqual, toItem: notesSlideView!, attribute: .bottom, multiplier: 1.0, constant: padding)])
        
        let notesCenterY = NSLayoutConstraint(item: notesSlideView!, attribute: .centerY, relatedBy: .equal, toItem: container, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        notesCenterY.priority = NSLayoutConstraint.Priority(750.0)
        let notesWidth = NSLayoutConstraint(item: notesSlideView!, attribute: .width, relatedBy: .equal, toItem: container, attribute: .width, multiplier: 0.9, constant: 0.0)
        notesWidth.priority = NSLayoutConstraint.Priority(260.0)
        container.addConstraints([notesWidth, notesCenterY])
    }
    
    
    func setupNotesTextView(in container: NSView) {
        // ScrollView setup
        let notesScrollView = NSScrollView()
        let contentSize = notesScrollView.contentSize
        notesScrollView.borderType = .noBorder
        notesScrollView.hasVerticalScroller = true
        notesScrollView.hasHorizontalScroller = false
        notesScrollView.translatesAutoresizingMaskIntoConstraints = false
        notesScrollView.backgroundColor = NSColor(white: 0.1, alpha: 1.0)
        
        // TextView setup
        notesTextView = NotesTextView(frame: .zero)
        notesTextView!.minSize = NSSize(width: 0, height: contentSize.height)
        notesTextView!.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        notesTextView!.isVerticallyResizable = true
        notesTextView!.isHorizontallyResizable = false
        notesTextView!.autoresizingMask = .width
        
        // Text container setup
        notesTextView!.textContainer?.containerSize = NSSize(width: contentSize.width, height: CGFloat.greatestFiniteMagnitude)
        notesTextView?.textContainer?.widthTracksTextView = true
        
        // Additional appearance setup for notes text field
        notesTextView!.backgroundColor = .black
        notesTextView!.setFontColor(.white)
        
        notesScrollView.documentView = notesTextView
        container.addSubview(notesScrollView)

        container.addConstraints([
            NSLayoutConstraint(item: notesScrollView, attribute: .centerX, relatedBy: .equal, toItem: container, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: notesScrollView, attribute: .centerY, relatedBy: .equal, toItem: container, attribute: .centerY, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: notesScrollView, attribute: .width, relatedBy: .equal, toItem: container, attribute: .width, multiplier: 0.9, constant: 0.0),
            NSLayoutConstraint(item: notesScrollView, attribute: .height, relatedBy: .equal, toItem: container, attribute: .height, multiplier: 0.8, constant: 0.0)
            ])
    }
}
