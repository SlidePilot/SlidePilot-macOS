//
//  PointerView.swift
//  Slidejar
//
//  Created by Pascal Braband on 25.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class PointerView: NSImageView {
    
    enum PointerType {
        case circle, cursor
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup(type: .circle)
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup(type: .circle)
    }
    
    
    init(frame frameRect: NSRect, type: PointerType) {
        super.init(frame: frameRect)
        setup(type: type)
    }
    
    
    func setup(type: PointerType) {
        switch type {
        case .circle:
            setupCircle()
        case .cursor:
            setupCursor()
        }
    }
    
    
    func setupCircle() {
        self.wantsLayer = true
        self.layer?.cornerRadius = min(self.frame.width, self.frame.height) / 2
        self.layer?.backgroundColor = NSColor(calibratedWhite: 0.5, alpha: 0.8).cgColor
        self.layer?.borderWidth = 5.0
        self.layer?.borderColor = .white

        self.shadow = NSShadow()
        self.layer?.shadowOpacity = 0.8
        self.layer?.shadowColor = .black
        self.layer?.shadowOffset = NSMakeSize(0, 0)
        self.layer?.shadowRadius = 10.0
    }
    
    
    func setupCursor() {
        let cursorImage = NSCursor.arrow.image
        self.frame = NSRect(x: self.frame.minX, y: self.frame.minY, width: cursorImage.size.width, height: cursorImage.size.height)
        self.image = cursorImage
    }
    
}
