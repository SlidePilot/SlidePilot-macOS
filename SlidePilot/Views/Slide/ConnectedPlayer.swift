//
//  ConnectedPlayer.swift
//  SlidePilot
//
//  Created by Pascal Braband on 01.10.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa
import AVKit

class ConnectedPlayer: AVPlayerView {
    
    var areControlsEnabled = true {
        didSet {
            if areControlsEnabled == false {
                self.controlsStyle = .none
            } else {
                self.controlsStyle = .default
            }
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override func keyDown(with event: NSEvent) {
        // Forward key events to window
        self.window?.keyDown(with: event)
        return
    }
    
    
    override var acceptsFirstResponder: Bool {
        return areControlsEnabled
    }
}
