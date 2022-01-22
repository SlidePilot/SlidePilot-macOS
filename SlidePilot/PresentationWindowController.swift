//
//  PresentationWindowController.swift
//  SlidePilot
//
//  Created by Pascal Braband on 24.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class PresentationWindowController: NSWindowController, NSWindowDelegate {
    internal var trackingTag: NSView.TrackingRectTag?

    override func mouseEntered(with event: NSEvent) {
        if trackingTag == event.trackingNumber {
            // show titlebar container (i.e. superview of superview of closebutton)
            self.window?.standardWindowButton(.closeButton)?.superview?.superview?.animator().alphaValue = 1
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        if trackingTag == event.trackingNumber {
            // hide titlebar container (i.e. superview of superview of closebutton)
            if let window = self.window {
                if !window.styleMask.contains(.fullScreen) {
                    window.standardWindowButton(.closeButton)?.superview?.superview?.animator().alphaValue = 0
                }
            }
        }
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()

        self.window?.title = NSLocalizedString("Presentation", comment: "Window name for the presentation view.")
        
        let view = self.window?.contentView
        trackingTag = view?.addTrackingRect(view!.bounds, owner: self, userData: nil, assumeInside: false)
    }
    
    func windowDidResize(_ notification: Notification) {
        if let view = self.window?.contentView {
            if let trackingTag = trackingTag { view.removeTrackingRect(trackingTag) }
            trackingTag = view.addTrackingRect(view.bounds, owner: self, userData: nil, assumeInside: false)
        }
    }
}
