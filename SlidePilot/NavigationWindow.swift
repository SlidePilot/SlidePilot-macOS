//
//  NavigationWindow.swift
//  SlidePilot
//
//  Created by Pascal Braband on 18.05.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class NavigationWindow: NSWindow {
    
    override func sendEvent(_ event: NSEvent) {
        // AVKit's private control responders handle arrows before AVPlayerView.
        // Intercept only within a movie, so text editing keeps its usual keys.
        if event.type == .keyDown,
           event.modifierFlags.intersection([.command, .control, .option]).isEmpty,
           [UInt16(123), 124, 125, 126, 116, 121].contains(event.keyCode) {
            var responder = firstResponder
            while let current = responder {
                if current is ConnectedPlayer {
                    keyDown(with: event)
                    return
                }
                responder = current.nextResponder
            }
        }
        super.sendEvent(event)
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 123 || event.keyCode == 126 || event.specialKey == NSEvent.SpecialKey.pageUp {
            PageController.previousPage(sender: self)
        } else if event.keyCode == 124 || event.keyCode == 125 || event.specialKey == NSEvent.SpecialKey.pageDown {
            PageController.nextPage(sender: self)
            if let appDelegate = NSApp.delegate as? AppDelegate {
                appDelegate.startTimerIfNeeded()
            }
        } else {
            super.keyDown(with: event)
        }
    }

}
