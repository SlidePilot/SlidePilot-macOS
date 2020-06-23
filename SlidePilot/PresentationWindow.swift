//
//  PresentationWindow.swift
//  SlidePilot
//
//  Created by Pascal Braband on 26.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class PresentationWindow: NavigationWindow {

    override var canBecomeKey: Bool {
        return canBecomeKeyPrivate
    }
    
    private var canBecomeKeyPrivate: Bool = false
    
    
    public func setCanBecomeKey(_ newValue: Bool) {
        canBecomeKeyPrivate = newValue
    }
}
