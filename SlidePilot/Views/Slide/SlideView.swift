//
//  SlideView.swift
//  SlidePilot
//
//  Created by Pascal Braband on 23.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa
import PDFKit

protocol SlideTrackingDelegate {
    /** `position` is the mouse position in the window. */
    func mouseMoved(to position: NSPoint, in sender: PDFPageView?)
}

class SlideView: NSView {
    
    var delegate: SlideTrackingDelegate?
    
    var label: NSTextField!
    var page: PDFPageView!
    private var container: NSView!
    
    var pageCount: Int? {
        return page?.pdfDocument?.pageCount
    }
    
    var heightConstraint: NSLayoutConstraint?
    
    // Pointer
    var pointer: PointerDisplayView!
    var isPointerDisplayed: Bool = false {
        didSet {
            pointer.isHidden = !isPointerDisplayed
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
    
    
    func setupView() {
        container = NSView(frame: .zero)
        container.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(container)
        self.addConstraints([
            NSLayoutConstraint(item: container!, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: container!, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: container!, attribute: .left, relatedBy: .greaterThanOrEqual, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self, attribute: .right, relatedBy: .greaterThanOrEqual, toItem: container!, attribute: .right, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: container!, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .greaterThanOrEqual, toItem: container!, attribute: .bottom, multiplier: 1.0, constant: 0.0)])
        
        let leftC = NSLayoutConstraint(item: container!, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0)
        leftC.priority = NSLayoutConstraint.Priority.defaultLow
        let rightC = NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: container!, attribute: .right, multiplier: 1.0, constant: 0.0)
        rightC.priority = NSLayoutConstraint.Priority.defaultLow
        let topC = NSLayoutConstraint(item: container!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0)
        topC.priority = NSLayoutConstraint.Priority.defaultLow
        let bottomC = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container!, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        bottomC.priority = NSLayoutConstraint.Priority.defaultLow
        let widthC = NSLayoutConstraint(item: container!, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1.0, constant: 0.0)
        widthC.priority = NSLayoutConstraint.Priority.defaultLow
        let heightC = NSLayoutConstraint(item: container!, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1.0, constant: 0.0)
        heightC.priority = NSLayoutConstraint.Priority.defaultLow
        self.addConstraints([leftC, rightC, topC, bottomC, widthC, heightC])
        
        
        // Setup slide view
        page = PDFPageView(frame: .zero)
        page.isAutoAspectRatioConstraintEnabled = true
        page!.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(page!)
        container.addConstraints([
            NSLayoutConstraint(item: page!, attribute: .left, relatedBy: .equal, toItem: container!, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: page!, attribute: .right, relatedBy: .equal, toItem: container!, attribute: .right, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: page!, attribute: .bottom, relatedBy: .equal, toItem: container!, attribute: .bottom, multiplier: 1.0, constant: 0.0)])
        page?.setContentCompressionResistancePriority(NSLayoutConstraint.Priority(rawValue: 250.0), for: .horizontal)
        page?.setContentCompressionResistancePriority(NSLayoutConstraint.Priority(rawValue: 250.0), for: .vertical)
        
        pointer = PointerDisplayView()
        pointer.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(pointer)
        container.addConstraints([
            NSLayoutConstraint(item: pointer!, attribute: .left, relatedBy: .equal, toItem: page!, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: pointer!, attribute: .right, relatedBy: .equal, toItem: page!, attribute: .right, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: pointer!, attribute: .top, relatedBy: .equal, toItem: page!, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: pointer!, attribute: .bottom, relatedBy: .equal, toItem: page!, attribute: .bottom, multiplier: 1.0, constant: 0.0)])
        pointer.isHidden = true
        
        
        // Setup info label for slide
        label = SlideInfoLabel(frame: .zero)
        
        label!.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label!)
        container.addConstraints([
            NSLayoutConstraint(item: label!, attribute: .left, relatedBy: .equal, toItem: container!, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: label!, attribute: .right, relatedBy: .equal, toItem: container!, attribute: .right, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: label!, attribute: .bottom, relatedBy: .equal, toItem: page!, attribute: .top, multiplier: 1.0, constant: -5.0),
            NSLayoutConstraint(item: label!, attribute: .top, relatedBy: .equal, toItem: container!, attribute: .top, multiplier: 1.0, constant: 5.0),
            NSLayoutConstraint(item: label!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 25.0)])
    }
    
    
    
    
    // MARK: - Mouse Tracking
    
    var trackingArea: NSTrackingArea?
    
    func addTrackingAreaForSlide() {
        // Remove old tracking area
        if trackingArea != nil {
            self.removeTrackingArea(trackingArea!)
            trackingArea = nil
        }
        
        // Create new tracking area
        guard let imageRect = page?.imageRect().insetBy(dx: -10, dy: -10) else { return }
        
        // Translate imageRect with PDFPageView's origin
        let trackingRect = NSRect(x: container.frame.minX + page.frame.minX + imageRect.minX,
                                  y: container.frame.minY + page.frame.minY + imageRect.minY,
                                  width: imageRect.width,
                                  height: imageRect.height)
        trackingArea = NSTrackingArea(rect: trackingRect, options: [.mouseEnteredAndExited, .mouseMoved, .activeInKeyWindow], owner: self, userInfo: nil)
        
        // Add tracking area
        self.addTrackingArea(trackingArea!)
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        addTrackingAreaForSlide()
    }
    
    
    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
        delegate?.mouseMoved(to: event.locationInWindow, in: page)
    }
    
    
    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        delegate?.mouseMoved(to: event.locationInWindow, in: page)
    }
    
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        delegate?.mouseMoved(to: event.locationInWindow, in: page)
    }
}
