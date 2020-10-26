//
//  PointerView.swift
//  SlidePilot
//
//  Created by Pascal Braband on 25.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class PointerView: NSImageView {
    
    enum PointerType: Int, Codable {
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
            setupPointer(with: NSCursor.arrow.image)
        case .dot:
            setupPointer(with: NSImage(named: "DotPointer")!)
        case .circle:
            setupPointer(with: NSImage(named: "CirclePointer")!)
        case .target:
            setupPointer(with: NSImage(named: "TargetPointer")!)
        case .targetColor:
            setupPointer(with: NSImage(named: "TargetPointerColor")!)
        }
    }
    
    
    func setupPointer(with image: NSImage) {
        self.frame = NSRect(x: self.frame.origin.x, y: self.frame.origin.y, width: image.size.width, height: image.size.height)
        self.image = image
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
