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
    
    
    private func setup(type: PointerType) {
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
        self.frame = NSRect(x: self.frame.origin.x, y: self.frame.origin.y, width: 40.0, height: 40.0)
        self.image = NSImage(named: "DotPointer")!
    }
    
    
    private func setupCircle() {
        self.frame = NSRect(x: self.frame.origin.x, y: self.frame.origin.y, width: 40.0, height: 40.0)
        self.image = NSImage(named: "CirclePointer")!
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
