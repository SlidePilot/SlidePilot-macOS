//
//  IconButton.swift
//  SlidePilot
//
//  Created by Pascal Braband on 16.06.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class IconButton: NSControl {

    /** The image do be displayed in the button*/
    var image: NSImage? {
        didSet {
            setupImageLayer()
        }
    }
    
    /**
     The color of the buttons background layer. Behavior differs based on `isToggle` property.
     
     - If `isToggle == false`: Then this is the color of the highlight layer for the button.
     - If `isToggle == true`: Then this is the background color of the button when `state == .on`.
     */
    var backgroundColor: NSColor = .black {
        didSet {
            backgroundLayer?.backgroundColor = backgroundColor.cgColor
        }
    }
    
    /**
     The color of the buttons. Only needed when `isToggle == true`. Then this is the color of the highlight layer for the button
    */
    var highlightColor: NSColor? = nil
    
    /** Determines if the button is a toggle or a push down button. */
    var isToggle: Bool = false
    
    /** The buttons state*/
    var state: StateValue = .off {
        didSet {
            // Only animate if value did change
            if self.state != oldValue {
                animateSelection()
                
                // Call target.action
                _ = target?.perform(action, with: self)
            }
        }
    }
    
    private var isMouseInside = false {
        didSet {
            // Only animate if value did change
            if self.isMouseInside != oldValue {
                if isMouseInside {
                    // Highlight if mouse entered
                    animateHighlight()
                } else {
                    // Remove highlight if mouse exited
                    animateDehighlight()
                }
            }
        }
    }
    
    // Layers
    private var imageLayer: CALayer?
    private var backgroundLayer: CALayer?
    
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    
    init(frame frameRect: NSRect, image: NSImage) {
        self.image = image
        super.init(frame: .zero)
        setup()
    }
    
    
    private func setup() {
        // Setup view
        self.translatesAutoresizingMaskIntoConstraints = false
        self.wantsLayer = true
        
        // Setup layer
        self.layer?.masksToBounds = false
        
        // Setup background layer
        backgroundLayer = CALayer()
        backgroundLayer?.backgroundColor = NSColor.blue.cgColor
        backgroundLayer?.frame = self.bounds
        backgroundLayer?.cornerRadius = 7.0
        backgroundLayer?.opacity = 0.0
        self.layer?.addSublayer(backgroundLayer!)
        
        // Setup image layer
        setupImageLayer()
    }
    
    
    private func setupImageLayer() {
        guard let image = self.image else { return }
        
        imageLayer?.removeFromSuperlayer()
        imageLayer = CALayer()
        var imageRect = NSRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        let imageRef = image.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
        imageLayer?.contents = imageRef
        imageLayer?.frame = imageRect
        
        imageLayer?.position = NSPoint(x: self.bounds.width/2, y: self.bounds.width/2)
        
        self.layer?.addSublayer(imageLayer!)
    }
    
    
    override func mouseDown(with event: NSEvent) {
        isMouseInside = true
    }
    
    
    override func mouseUp(with event: NSEvent) {
        if isMouseInside {
            isMouseInside = false
            
            // Toggle state
            if isToggle {
                state = state == .on ? .off : .on
            } else {
                // Call target action
                _ = target?.perform(action, with: self)
            }
        }
    }
    
    
    override func mouseDragged(with event: NSEvent) {
        let mouseLocationInView = self.window?.contentView?.convert(event.locationInWindow, to: self)
        if self.bounds.contains(mouseLocationInView ?? .zero) {
            isMouseInside = true
        } else {
            isMouseInside = false
        }
    }
    
    
    private func animateSelection() {
        if state == .on {
            backgroundLayer?.backgroundColor = backgroundColor.cgColor
            backgroundLayer?.opacity = 1.0
        } else {
            animateDehighlight()
        }
    }
    
    
    private func animateHighlight() {
        if isToggle {
            if highlightColor == nil {
                if #available(OSX 10.14, *) {
                    highlightColor = backgroundColor.withSystemEffect(.pressed)
                } else {
                    highlightColor = backgroundColor.blended(withFraction: 0.15, of: .black)
                }
            }
            
            backgroundLayer?.backgroundColor = highlightColor!.cgColor
        }
        backgroundLayer?.opacity = 1.0
    }
    
    
    private func animateDehighlight() {
        backgroundLayer?.opacity = 0.0
    }
    
    
    override func updateLayer() {
        super.updateLayer()
        
        setupImageLayer()
        backgroundLayer?.frame = self.bounds
    }
    
    
    var trackingArea: NSTrackingArea?
    
    func addTrackingArea() {
        // Remove old tracking area
        if trackingArea != nil {
            self.removeTrackingArea(trackingArea!)
            trackingArea = nil
        }
        
        trackingArea = NSTrackingArea(rect: self.bounds, options: [.mouseEnteredAndExited, .activeInKeyWindow], owner: self, userInfo: nil)
        
        // Add tracking area
        self.addTrackingArea(trackingArea!)
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        addTrackingArea()
    }
    
}

