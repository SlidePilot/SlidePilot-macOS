//
//  Clipfree.swift
//  SlidePilot
//
//  Created by Pascal Braband on 31.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class ClipfreeView: NSView {

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        layer = NoClippingLayer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        layer = NoClippingLayer()
    }
}


class NoClippingLayer: CALayer {
    override var masksToBounds: Bool {
        set {

        }
        get {
            return false
        }
    }
}
