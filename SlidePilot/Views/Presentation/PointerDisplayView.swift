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
    
    var pointer: PointerCCView?
    
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    
    private func setup() {
        DisplayController.subscribePointerAppearance(target: self, action: #selector(pointerAppearanceDidChange(_:)))
        DisplayController.subscribeDisplayPointer(target: self, action: #selector(displayPointerDidChange(_:)))
    }
    
    
    override func resetCursorRects() {
        super.resetCursorRects()
        
        // Add cursor rect for whole view
        addPointerRect()
    }
    
    
    /** Adds cursor rect for the whole view. When hovering over the view, the corresponding cursor will be displayed. */
    private func addPointerRect() {
        guard DisplayController.isPointerDisplayed else { return }
        
        if pointer == nil {
            pointer = PointerCCView(configuration: DisplayController.pointerAppearance)
        }
        pointer?.wantsLayer = true
        pointer?.draw(CGRect(x: 0, y: 0, width: 10, height: 10))
        guard let cursorImage = pointer?.image() else { return }
        let cursor = NSCursor(image: cursorImage, hotSpot: (pointer?.hotspot ?? NSPoint(x: 0, y: 0)))
        
        addCursorRect(self.bounds, cursor: cursor)
    }
    
    
    var trackingArea: NSTrackingArea?
       
    private func addTrackingArea() {
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
            pointer = PointerCCView(configuration: DisplayController.pointerAppearance)
            pointer?.setPosition(NSPoint(x: self.frame.midX, y: self.frame.midY))
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
        pointer?.load(DisplayController.pointerAppearance)
    }
    
    
    @objc func displayPointerDidChange(_ notification: Notification) {
        self.window?.invalidateCursorRects(for: self)
        pointer?.load(DisplayController.pointerAppearance)
    }
    
}
