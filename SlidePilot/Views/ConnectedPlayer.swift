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
    
    static let sharedPlayersChangedNotification = Notification.Name(rawValue: "sharedPlayersChangedNotification")
    static var sharedPlayers: [AVPlayer]? {
        didSet {
            // Send notification, that sharedPlayers changed
            NotificationCenter.default.post(name: sharedPlayersChangedNotification, object: nil)
        }
    }
    
    var connectToSharedPlayer: Bool = false {
        didSet {
            connect()
            
            // Subscribe to changes on sharedPlayers variable
            if connectToSharedPlayer {
                subscribeSharedPlayers()
            } else {
                unsubscribeSharedPlayers()
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
    
    
    
    
    override func keyDown(with event: NSEvent) {
        // Forward key events to window
        self.window?.keyDown(with: event)
        return
    }
    
    
    override var acceptsFirstResponder: Bool {
        return areControlsEnabled
    }
    
    
    @objc private func connect() {
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
    
    
    private func subscribeSharedPlayers() {
        // When shared player changed, update the connection
        NotificationCenter.default.addObserver(self, selector: #selector(connect), name: Self.sharedPlayersChangedNotification, object: nil)
    }
    
    
    private func unsubscribeSharedPlayers() {
        NotificationCenter.default.removeObserver(self, name: Self.sharedPlayersChangedNotification, object: nil)
    }
}
