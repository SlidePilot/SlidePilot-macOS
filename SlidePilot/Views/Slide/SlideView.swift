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
    
    var label: NSTextField?
    var page: PDFPageView?
    
    var pageCount: Int? {
        return page?.pdfDocument?.pageCount
    }
    
    var pdfDocument: PDFDocument? {
        set {
            self.page?.pdfDocument = newValue
        }
        get {
            return self.page?.pdfDocument
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
        // Setup info label for slide
        label = NSTextField(frame: .zero)
        label!.font = NSFont.systemFont(ofSize: 20.0, weight: .regular)
        label!.alignment = .center
        label!.isEditable = false
        label!.isSelectable = false
        label!.isBordered = false
        label!.drawsBackground = false
        label!.textColor = .white
        
        label!.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label!)
        self.addConstraints([NSLayoutConstraint(item: label!, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0),
                             NSLayoutConstraint(item: label!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
                             NSLayoutConstraint(item: label!, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0),
                             NSLayoutConstraint(item: label!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 20.0)])
        
        // Setup slide view
        page = PDFPageView(frame: .zero)
        page!.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(page!)
        self.addConstraints([NSLayoutConstraint(item: page!, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0),
                             NSLayoutConstraint(item: page!, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0),
                             NSLayoutConstraint(item: page!, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0), NSLayoutConstraint(item: page!, attribute: .top, relatedBy: .equal, toItem: label!, attribute: .bottom, multiplier: 1.0, constant: 10.0)])
        page?.setContentCompressionResistancePriority(NSLayoutConstraint.Priority(rawValue: 250.0), for: .horizontal)
        page?.setContentCompressionResistancePriority(NSLayoutConstraint.Priority(rawValue: 250.0), for: .vertical)
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
        trackingArea = NSTrackingArea(rect: imageRect, options: [.mouseEnteredAndExited, .mouseMoved, .activeInKeyWindow], owner: self, userInfo: nil)
        
        // Add tracking area
        self.addTrackingArea(trackingArea!)
    }
    
    override func updateTrackingAreas() {
        addTrackingAreaForSlide()
    }
    
    
    override func mouseMoved(with event: NSEvent) {
        delegate?.mouseMoved(to: event.locationInWindow, in: page)
        
    }
}
