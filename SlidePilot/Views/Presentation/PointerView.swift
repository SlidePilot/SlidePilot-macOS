//
//  PointerView.swift
//  SlidePilot
//
//  Created by Pascal Braband on 25.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class PointerView: NSImageView {
    
    enum PointerType {
        case cursor, dot, circle, target, targetColor
    }
    
    var type: PointerType {
        didSet {
            setup(type: type)
        }
    }
    

    override init(frame frameRect: NSRect) {
        self.type = .cursor
        super.init(frame: frameRect)
        setup(type: self.type)
    }
    
    
    required init?(coder: NSCoder) {
        self.type = .cursor
        super.init(coder: coder)
        setup(type: self.type)
    }
    
    
    init(origin: NSPoint, type: PointerType) {
        self.type = type
        super.init(frame: .zero)
        setup(type: self.type)
    }
    
    
    private func resetAppearance() {
        self.image = nil
        
        self.layer?.cornerRadius = 0
        self.layer?.backgroundColor = .clear
        self.layer?.borderWidth = 0
        self.layer?.borderColor = .clear

        self.shadow = nil
        self.layer?.shadowOpacity = 0
        self.layer?.shadowColor = .clear
        self.layer?.shadowOffset = NSMakeSize(0, 0)
        self.layer?.shadowRadius = 0.0
    }
    
    
    private func setup(type: PointerType) {
        resetAppearance()
        switch type {
        case .cursor:
            setupCursor()
        case .dot:
            setupDot()
        case .circle:
            setupCircle()
        case .target:
            setupTarget()
        case .targetColor:
            setupTargetColor()
        }
    }
    
    
    private func setupCursor() {
        let cursorImage = NSCursor.arrow.image
        self.frame = NSRect(x: self.frame.origin.x, y: self.frame.origin.y, width: cursorImage.size.width, height: cursorImage.size.height)
        self.image = cursorImage
    }
    
    
    private func setupDot() {
        self.frame = NSRect(x: self.frame.origin.x, y: self.frame.origin.y, width: 10.0, height: 10.0)
            
        self.wantsLayer = true
        self.layer?.cornerRadius = min(self.frame.width, self.frame.height) / 2
//        self.layer?.backgroundColor = NSColor(calibratedWhite: 0.0, alpha: 0.8).cgColor
        self.layer?.backgroundColor = NSColor(red: 36.0/255.0, green: 60.0/255.0, blue: 133.0/255.0, alpha: 1.0).cgColor
        self.layer?.borderWidth = 2.0
        self.layer?.borderColor = .white

        self.shadow = NSShadow()
        self.layer?.shadowOpacity = 0.6
        self.layer?.shadowColor = .black
        self.layer?.shadowOffset = NSMakeSize(0, 0)
        self.layer?.shadowRadius = 5.0
    }
    
    
    private func setupCircle() {
        self.frame = NSRect(x: self.frame.origin.x, y: self.frame.origin.y, width: 20.0, height: 20.0)
        
        self.wantsLayer = true
        self.layer?.cornerRadius = min(self.frame.width, self.frame.height) / 2
        self.layer?.backgroundColor = .clear
        self.layer?.borderWidth = 3
        self.layer?.borderColor = .white

        self.shadow = NSShadow()
        self.layer?.shadowOpacity = 0.6
        self.layer?.shadowColor = .black
        self.layer?.shadowOffset = NSMakeSize(0, 0)
        self.layer?.shadowRadius = 5.0
    }
    
    
    private func setupTarget() {
        self.frame = NSRect(x: self.frame.origin.x, y: self.frame.origin.y, width: 44.0, height: 44.0)
        self.image = NSImage(named: "TargetPointer")!
    }
    
    
    private func setupTargetColor() {
        self.frame = NSRect(x: self.frame.origin.x, y: self.frame.origin.y, width: 44.0, height: 44.0)
        self.image = NSImage(named: "TargetPointerColor")!
    }
    
    
    public func setPosition(_ position: NSPoint) {
        var pointerPosition = position
        switch self.type {
        case .cursor:
            pointerPosition.x -= 4
            pointerPosition.y = pointerPosition.y - self.bounds.height + 4
        case .dot, .circle, .target, .targetColor:
            pointerPosition.x -= self.bounds.width / 2
            pointerPosition.y -= self.bounds.height / 2
        }
        
        self.frame.origin = pointerPosition
    }
}
