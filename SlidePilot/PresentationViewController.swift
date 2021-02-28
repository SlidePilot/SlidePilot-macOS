//
//  PresentationViewController.swift
//  SlidePilot
//
//  Created by Pascal Braband on 24.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class PresentationViewController: NSViewController {

    var pageView: PDFPageView!
    var pointer: PointerDisplayView?
    var isPointerShown: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.black.cgColor
        
        // Setup pageView
        pageView = PDFPageView(frame: .zero)
        pageView.translatesAutoresizingMaskIntoConstraints = false
        pageView.isAutoAspectRatioConstraintEnabled = true
        self.view.addSubview(pageView)
        self.view.addConstraints([
            NSLayoutConstraint(item: pageView!, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: pageView!, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: pageView!, attribute: .left, relatedBy: .greaterThanOrEqual, toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.view, attribute: .right, relatedBy: .greaterThanOrEqual, toItem: pageView, attribute: .right, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: pageView!, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.view, attribute: .bottom, relatedBy: .greaterThanOrEqual, toItem: pageView, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: pageView!, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 200.0),
            NSLayoutConstraint(item: pageView!, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 200.0)])
        
        let leftC = NSLayoutConstraint(item: pageView!, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0.0)
        leftC.priority = NSLayoutConstraint.Priority.defaultLow
        let rightC = NSLayoutConstraint(item: self.view, attribute: .right, relatedBy: .equal, toItem: pageView, attribute: .right, multiplier: 1.0, constant: 0.0)
        rightC.priority = NSLayoutConstraint.Priority.defaultLow
        let topC = NSLayoutConstraint(item: pageView!, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0.0)
        topC.priority = NSLayoutConstraint.Priority.defaultLow
        let bottomC = NSLayoutConstraint(item: self.view, attribute: .bottom, relatedBy: .equal, toItem: pageView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        bottomC.priority = NSLayoutConstraint.Priority.defaultLow
        let widthC = NSLayoutConstraint(item: pageView!, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1.0, constant: 0.0)
        widthC.priority = NSLayoutConstraint.Priority.defaultLow
        let heightC = NSLayoutConstraint(item: pageView!, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 1.0, constant: 0.0)
        heightC.priority = NSLayoutConstraint.Priority.defaultLow
        self.view.addConstraints([leftC, rightC, topC, bottomC, widthC, heightC])
        
        pageView.setContentCompressionResistancePriority(NSLayoutConstraint.Priority(rawValue: 250.0), for: .horizontal)
        pageView.setContentCompressionResistancePriority(NSLayoutConstraint.Priority(rawValue: 250.0), for: .vertical)
        
        // Video Player settings and connect to main player(s)
        pageView.areVideoPlayerControlsEnabled = false
        pageView.connectToCurrentPlayer = true
        
        
        pointer = PointerDisplayView()
        pointer?.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(pointer!)
        self.view.addConstraints([
            NSLayoutConstraint(item: pointer!, attribute: .left, relatedBy: .equal, toItem: pageView!, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: pointer!, attribute: .right, relatedBy: .equal, toItem: pageView!, attribute: .right, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: pointer!, attribute: .top, relatedBy: .equal, toItem: pageView!, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: pointer!, attribute: .bottom, relatedBy: .equal, toItem: pageView!, attribute: .bottom, multiplier: 1.0, constant: 0.0)])
        
        // Subscribe to page changes
        PageController.subscribe(target: self, action: #selector(pageDidChange(_:)))
        
        // Subscribe to document changes
        DocumentController.subscribeDidOpenDocument(target: self, action: #selector(documentDidChange(_:)))
        
        // Subscribe to display changes
        DisplayController.subscribeNotesPosition(target: self, action: #selector(notesPositionDidChange(_:)))
        DisplayController.subscribeDisplayBlackCurtain(target: self, action: #selector(displayBlackCurtainDidChange(_:)))
        DisplayController.subscribeDisplayWhiteCurtain(target: self, action: #selector(displayWhiteCurtainDidChange(_:)))
        DisplayController.subscribeDisplayDrawingTools(target: self, action: #selector(displayDrawingToolsDidChange(_:)))
    }
    
    
    
    
    // MARK: - Canvas
    
    var canvas: CanvasView?
    
    func showCanvas() {
        if canvas == nil {
            canvas = CanvasView(frame: .zero)
            canvas!.translatesAutoresizingMaskIntoConstraints = false
            canvas!.allowsDrawing = false
            self.view.addSubview(canvas!, positioned: .below, relativeTo: pointer!)
            self.view.addConstraints([
                NSLayoutConstraint(item: canvas!, attribute: .left, relatedBy: .equal, toItem: pageView, attribute: .left, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: canvas!, attribute: .right, relatedBy: .equal, toItem: pageView, attribute: .right, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: canvas!, attribute: .top, relatedBy: .equal, toItem: pageView, attribute: .top, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: canvas!, attribute: .bottom, relatedBy: .equal, toItem: pageView, attribute: .bottom, multiplier: 1.0, constant: 0.0)])
        }
        
        canvas?.isHidden = false
    }
    
    
    func hideCanvas() {
        canvas?.isHidden = true
    }
    
    
    
    
    // MARK: - Control Handlers
    
    @objc private func pageDidChange(_ notification: Notification) {
        pageView.setCurrentPage(PageController.currentPage)
    }
    
    
    @objc func documentDidChange(_ notification: Notification) {
        pageView.setDocument(DocumentController.document)
    }
    
    
    @objc func notesPositionDidChange(_ notification: Notification) {
        pageView.setDisplayMode(DisplayController.notesPosition.displayModeForPresentation())
    }
    
    
    @objc func displayBlackCurtainDidChange(_ notification: Notification) {
        // Un-/Cover screen with black curtain, depending on isWhiteCurtainDisplay
        if DisplayController.isBlackCurtainDisplayed {
            pageView.coverBlack()
            hideCanvas()
        } else {
            pageView.uncover()
            if DisplayController.areDrawingToolsDisplayed { showCanvas() }
        }
    }
    
    
    @objc func displayWhiteCurtainDidChange(_ notification: Notification) {
        // Un-/Cover screen with white curtain, depending on isWhiteCurtainDisplay
        if DisplayController.isWhiteCurtainDisplayed {
            pageView.coverWhite()
            hideCanvas()
        } else {
            pageView.uncover()
            if DisplayController.areDrawingToolsDisplayed { showCanvas() }
        }
    }
    
    
    @objc func displayDrawingToolsDidChange(_ notification: Notification) {
        if DisplayController.areDrawingToolsDisplayed {
            showCanvas()
        } else {
            hideCanvas()
        }
    }
}




extension PresentationViewController: MousePointerDelegate {
    
    func showPointer() {
        pointer?.showPointer()
    }
    
    
    func hidePointer() {
        pointer?.hidePointer()
    }
    
    
    func pointerMoved(to position: NSPoint) {
        pointer?.setPointerPosition(to: position)
    }
    
    
    func calculateAbsolutePosition(for position: NSPoint, in view: NSImageView) -> NSPoint {
        let imageViewOrigin = view.frame.origin
        let imageFrame = view.imageRect()
        let imageOrigin = imageFrame.origin
        
        // Calculate absolute position in displayed image
        let absoluteInImage = NSPoint(x: imageFrame.width * position.x, y: imageFrame.height * position.y)
        
        // Calculate absolute position in view
        let absoluteInView = NSPoint(x: absoluteInImage.x + imageViewOrigin.x + imageOrigin.x,
                                     y: absoluteInImage.y + imageViewOrigin.y + imageOrigin.y)
        
        return absoluteInView
    }
}
