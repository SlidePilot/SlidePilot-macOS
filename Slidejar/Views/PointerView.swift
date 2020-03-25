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
    
    let type: PointerType
    

    override init(frame frameRect: NSRect) {
        self.type = .circle
        super.init(frame: frameRect)
        setup(type: self.type)
    }
    
    
    required init?(coder: NSCoder) {
        self.type = .circle
        super.init(coder: coder)
        setup(type: self.type)
    }
    
    
    init(frame frameRect: NSRect, type: PointerType) {
        self.type = type
        super.init(frame: frameRect)
        setup(type: self.type)
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
        self.layer?.borderWidth = 2.5
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
    
    
    func setPosition(_ position: NSPoint) {
        var pointerPosition = position
        switch self.type {
        case .circle:
            pointerPosition.x -= self.bounds.width / 2
            pointerPosition.y -= self.bounds.height / 2
        case .cursor:
            pointerPosition.x -= 4
            pointerPosition.y = pointerPosition.y - self.bounds.height + 4
        }
        
        self.frame.origin = pointerPosition
    }
}