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
    
    static var sharedPlayers: [AVPlayer]?
    
    var connectToSharedPlayer: Bool = false {
        didSet {
            if connectToSharedPlayer {
                // Replace own player with one of the shared players, if they have the same url
                guard let sharedPlayerCounterpart = ConnectedPlayer.sharedPlayers?.first(where: {
                    guard let sharedPlayerURL = ($0.currentItem?.asset as? AVURLAsset)?.url else { return false }
                    guard let ownPlayerURL = (self.player?.currentItem?.asset as? AVURLAsset)?.url else { return false }
                    return sharedPlayerURL == ownPlayerURL
                }) else { return }
                self.player = sharedPlayerCounterpart
            }
        }
    }
    
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
