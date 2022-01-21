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
            // show titlebar (i.e. superview of closebutton)
            self.window?.standardWindowButton(.closeButton)?.superview?.animator().alphaValue = 1
            if #available(OSX 11.0, *) {
                self.window?.titlebarSeparatorStyle = .shadow
            }
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        if trackingTag == event.trackingNumber {
            // hide titlebar (i.e. superview of closebutton)
            self.window?.standardWindowButton(.closeButton)?.superview?.animator().alphaValue = 0
            if #available(OSX 11.0, *) {
                self.window?.titlebarSeparatorStyle = .none
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
