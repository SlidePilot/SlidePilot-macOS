//
//  PointerDisplayView.swift
//  SlidePilot
//
//  Created by Pascal Braband on 22.06.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

// This class allows to display the current pointer from DisplayController when hvoering the cursor over this view and also allows braodcasting a cursor, using setPointerPosition
class PointerDisplayView: ClipfreeView {
    
    var pointer: PointerView?
    
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    
    func setup() {
        DisplayController.subscribePointerAppearance(target: self, action: #selector(pointerAppearanceDidChange(_:)))
        DisplayController.subscribeDisplayPointer(target: self, action: #selector(displayPointerDidChange(_:)))
    }
    
    
    override func resetCursorRects() {
        super.resetCursorRects()
        
        // Add cursor rect for whole view
        addPointerRect()
    }
    
    
    /** Adds cursor rect for where clickable annotations are. */
    private func addPointerRect() {
        guard DisplayController.isPointerDisplayed else { return }
        var cursor: NSCursor!
        switch DisplayController.pointerAppearance {
        case .cursor:
            cursor = NSCursor.arrow
        case .circle:
            let cursorImage = NSImage(named: "CirclePointer")!
            cursor = NSCursor(image: cursorImage, hotSpot: NSPoint(x: cursorImage.size.width/2, y: cursorImage.size.height/2))
        case .dot:
            let cursorImage = NSImage(named: "DotPointer")!
            cursor = NSCursor(image: cursorImage, hotSpot: NSPoint(x: cursorImage.size.width/2, y: cursorImage.size.height/2))
        case .target:
            let cursorImage = NSImage(named: "TargetPointer")!
            cursor = NSCursor(image: cursorImage, hotSpot: NSPoint(x: cursorImage.size.width/2, y: cursorImage.size.height/2))
        case .targetColor:
            let cursorImage = NSImage(named: "TargetPointerColor")!
            cursor = NSCursor(image: cursorImage, hotSpot: NSPoint(x: cursorImage.size.width/2, y: cursorImage.size.height/2))
        }
        
        addCursorRect(self.bounds, cursor: cursor)
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
    
    
    override func mouseEntered(with event: NSEvent) {
        hidePointer()
    }
    
    
    
    
    // MARK: - Manual Pointer Positioning
    
    /**
     Receives a relative point (from minimum (0.0, 0.0) to maximum (1.0, 1.0)) and sets the pointer position to the absolute coordinates in this view.
     */
    func setPointerPosition(to position: NSPoint) {
        // Calculate absolute position in view
        let absoluteInView = NSPoint(x: self.bounds.width * position.x,
                                     y: self.bounds.height * position.y)
        
        pointer?.setPosition(absoluteInView)
    }
    
    
    func showPointer() {
        if pointer == nil {
            pointer = PointerView(origin: NSPoint(x: self.frame.midX, y: self.frame.midY), type: DisplayController.pointerAppearance)
            self.addSubview(pointer!)
        }
    }
    
    
    func hidePointer() {
        pointer?.removeFromSuperview()
        pointer = nil
    }
    
    
    
    
    // MARK: - Control Handlers
    
    @objc func pointerAppearanceDidChange(_ notification: Notification) {
        self.window?.invalidateCursorRects(for: self)
        pointer?.type = DisplayController.pointerAppearance
    }
    
    
    @objc func displayPointerDidChange(_ notification: Notification) {
        self.window?.invalidateCursorRects(for: self)
    }
    
}
