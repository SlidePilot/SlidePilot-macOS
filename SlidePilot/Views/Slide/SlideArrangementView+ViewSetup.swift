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
    
    func setupLayout(displayCurrent: Bool, displayNext: Bool, displayNotes: Bool, displayDrawing: Bool, notesMode: DisplayController.NotesMode) {
        willSwitchLayout()
        
        clearView()
        
        // Setup drawing
        if DisplayController.areDrawingToolsDisplayed {
            setupSlidesLayoutCurrentDrawing()
        } else {
            // Rendering based on DisplayController.layoutConfiguration
            switch (DisplayController.layoutConfiguration.type) {
            case .single:
                setupSingleArrangement()
            case .double:
                setupDoubleArrangement()
            case .tripleLeft:
                setupTripleLeftArrangement()
            case .tripleRight:
                setupTripleRightArrangement()
            default:
                break
            }
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
    
    
    private func setupSlidesLayoutCurrentDrawing() {
        splitView?.isHidden = true
        
        currentSlideView = setupSlideView(in: self, isPointerDelegate: true, topPadding: 0, bottomPadding: padding + 60)
        
        // Setup Canvas
        let canvas = CanvasView(frame: .zero)
        canvas.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(canvas)
        self.addConstraints([
            NSLayoutConstraint(item: canvas, attribute: .left, relatedBy: .equal, toItem: currentSlideView!.page, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: canvas, attribute: .right, relatedBy: .equal, toItem: currentSlideView!.page, attribute: .right, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: canvas, attribute: .top, relatedBy: .equal, toItem: currentSlideView!.page, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: canvas, attribute: .bottom, relatedBy: .equal, toItem: currentSlideView!.page, attribute: .bottom, multiplier: 1.0, constant: 0.0)])
        
        self.window?.makeFirstResponder(canvas)
    }
    
    
    private func setupSingleArrangement() {
        splitView?.isHidden = true
        
        // Setup slide in container
        let slide = DisplayController.layoutConfiguration.slides[0]
        setupSlideView(for: slide, container: self, isPointerDelegate: (slide == .current))
    }
    
    
    private func setupDoubleArrangement() {
        guard splitView != nil, leftContainer != nil, rightContainer != nil else { return }
        splitView?.isHidden = false
        
        // Setup slides in containers
        let slide1 = DisplayController.layoutConfiguration.slides[0]
        let slide2 = DisplayController.layoutConfiguration.slides[1]
        setupSlideView(for: slide1, container: leftContainer!, isPointerDelegate: (slide1 == .current))
        setupSlideView(for: slide2, container: rightContainer!, isPointerDelegate: (slide2 == .current))
        
        splitView?.setHoldingPriority(NSLayoutConstraint.Priority(270.0), forSubviewAt: 0)
        splitView?.setHoldingPriority(NSLayoutConstraint.Priority(270.0), forSubviewAt: 1)
    }
    
    
    private func setupTripleLeftArrangement() {
        setupTripleArrangement(fullContainer: leftContainer!, stackContainer: rightContainer!)
    }
    
    
    private func setupTripleRightArrangement() {
        setupTripleArrangement(fullContainer: rightContainer!, stackContainer: leftContainer!)
    }
    
    
    private func setupTripleArrangement(fullContainer: NSView, stackContainer: NSView) {
        guard splitView != nil, leftContainer != nil, rightContainer != nil else { return }
        splitView?.isHidden = false
        
        // Setup slides in containers
        let slide1 = DisplayController.layoutConfiguration.slides[0]
        let slide2 = DisplayController.layoutConfiguration.slides[1]
        let slide3 = DisplayController.layoutConfiguration.slides[2]
        
        let (topContainer, bottomContainer) = createVerticallyStackedViews(in: stackContainer)
        setupSlideView(for: slide1, container: topContainer, isPointerDelegate: (slide1 == .current), bottomPadding: padding/2)
        setupSlideView(for: slide2, container: bottomContainer, isPointerDelegate: (slide2 == .current), topPadding: padding/2)
        setupSlideView(for: slide3, container: fullContainer, isPointerDelegate: (slide3 == .current))
    }
    
    
    /**
     Creates two vertically stacked containers in the given container.
     
     - returns:
     Two `NSView`'s, the first is the top container, the second is the bottom container.
     */
    func createVerticallyStackedViews(in container: NSView) -> (NSView, NSView) {
        // Create top container
        let topContainer = NSView()
        topContainer.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(topContainer)
        container.addConstraints([
            NSLayoutConstraint(item: topContainer, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: topContainer, attribute: .left, relatedBy: .equal, toItem: container, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: topContainer, attribute: .right, relatedBy: .equal, toItem: container, attribute: .right, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: topContainer, attribute: .height, relatedBy: .equal, toItem: container, attribute: .height, multiplier: 0.5, constant: 0.0)])
        
        let bottomContainer = NSView()
        bottomContainer.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(bottomContainer)
        container.addConstraints([
            NSLayoutConstraint(item: bottomContainer, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: bottomContainer, attribute: .left, relatedBy: .equal, toItem: container, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: bottomContainer, attribute: .right, relatedBy: .equal, toItem: container, attribute: .right, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: bottomContainer, attribute: .height, relatedBy: .equal, toItem: container, attribute: .height, multiplier: 0.5, constant: 0.0)])
        
        return (topContainer, bottomContainer)
    }
    
    
    /**
     Add a `SlideView` in a given container, setting up the required constraints. There are several options for padding.
     
     If there is no padding given for a constraint, this method will fallback on the default padding. This method will first look at the most specified padding (left, right, top, bottom), then on the paddings defined for the axis (vertical, horizontal), then for the overall padding and finally fallback on the default padding.
     
     - parameters:
         - container: The superview, where the `SlideView` should be embedded in.
         - isPointerDelegate: Determines, whether `self` should be set as delegate for this `SlideView` and if the pointer is shown.
         - padding: The overall padding, applied to the constraints on all four side.
         - verticalPadding: The padding applied to constraints on the vertical axis (top, bottom).
         - horizontalPadding: The padding applied to constraints on the horizontal axis (left, right).
         - topPadding: The padding applied to the top constraint.
         - bottomPadding: The padding applied to the bottom constraint.
         - leftPadding: The padding applied to the left constraint.
         - rightPadding: The padding applied to the right constraint.
     */
    func setupSlideView(in container: NSView, isPointerDelegate: Bool = false, padding: CGFloat? = nil, verticalPadding: CGFloat? = nil, horizontalPadding: CGFloat? = nil, topPadding: CGFloat? = nil, bottomPadding: CGFloat? = nil, leftPadding: CGFloat? = nil, rightPadding: CGFloat? = nil) -> SlideView {
        let slideView = SlideView(frame: .zero)
        slideView.page.setDocument(DocumentController.document)
        slideView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(slideView)
        container.addConstraints([
            NSLayoutConstraint(item: slideView, attribute: .left, relatedBy: .equal, toItem: container, attribute: .left, multiplier: 1.0, constant: (leftPadding ?? horizontalPadding ?? padding ?? self.padding)),
            NSLayoutConstraint(item: container, attribute: .right, relatedBy: .equal, toItem: slideView, attribute: .right, multiplier: 1.0, constant: (rightPadding ?? horizontalPadding ?? padding ?? self.padding)),
            NSLayoutConstraint(item: slideView, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: (topPadding ?? verticalPadding ?? padding ?? self.padding)),
            NSLayoutConstraint(item: container, attribute: .bottom, relatedBy: .equal, toItem: slideView, attribute: .bottom, multiplier: 1.0, constant: (bottomPadding ?? verticalPadding ?? padding ?? self.padding))])
        
        if isPointerDelegate {
            slideView.delegate = self
            slideView.isPointerDisplayed = true
        }
        
        return slideView
    }
    
    
    /**
     Add a `SlideView` or `NotesEditor` in a given container for a specified slide type.
     */
    private func setupSlideView(for slide: SlideType, container: NSView, isPointerDelegate: Bool = false, padding: CGFloat? = nil, verticalPadding: CGFloat? = nil, horizontalPadding: CGFloat? = nil, topPadding: CGFloat? = nil, bottomPadding: CGFloat? = nil, leftPadding: CGFloat? = nil, rightPadding: CGFloat? = nil) {
        
        if DisplayController.notesMode == .text,
           slide == .notes {
            setupNotesTextView(in: container)
        } else {
            let slideView = setupSlideView(in: container, isPointerDelegate: isPointerDelegate, padding: padding, verticalPadding: verticalPadding, horizontalPadding: horizontalPadding, topPadding: topPadding, bottomPadding: bottomPadding, leftPadding: leftPadding, rightPadding: rightPadding)
            
            switch slide {
            case .current:
                currentSlideView = slideView
            case .next:
                nextSlideView = slideView
            case .notes:
                notesSlideView = slideView
            }
        }
        
        
    }
    
    
    /**
     Add notes text view in a given container.
     */
    func setupNotesTextView(in container: NSView) {
        // Notes Editor setup
        if notesEditor == nil {
            notesEditor = NotesEditor(frame: .zero)
        }
        notesEditor!.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(notesEditor!)
        container.addConstraints([
            NSLayoutConstraint(item: notesEditor!, attribute: .centerX, relatedBy: .equal, toItem: container, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: notesEditor!, attribute: .centerY, relatedBy: .equal, toItem: container, attribute: .centerY, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: notesEditor!, attribute: .width, relatedBy: .equal, toItem: container, attribute: .width, multiplier: 0.9, constant: 0.0),
            NSLayoutConstraint(item: notesEditor!, attribute: .height, relatedBy: .equal, toItem: container, attribute: .height, multiplier: 0.8, constant: 0.0)
            ])
    }
}
