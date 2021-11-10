//
//  SlideSymbolView.swift
//  SlidePilot
//
//  Created by Pascal Braband on 09.11.21.
//  Copyright © 2021 Pascal Braband. All rights reserved.
//

import Cocoa

class SlideSymbolView: NSView {
    
    var type: SlideType? = nil {
        didSet {
            self.needsDisplay = true
        }
    }
    
    var isDraggable: Bool = false
    
    init(type: SlideType?) {
        super.init(frame: .zero)
        self.type = type
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        self.wantsLayer = true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Remove all layers
        self.layer?.sublayers?.forEach({ $0.removeFromSuperlayer() })
        
        // Set corner radius
        self.layer?.cornerRadius = min(self.frame.width, self.frame.height) * 0.2
        
        switch type {
        case .current:
            self.layer?.backgroundColor = NSColor(red: 108.0/255.0, green: 173.0/255.0, blue: 232.0/255.0, alpha: 1.0).cgColor
        case .next:
            self.layer?.backgroundColor = NSColor(red: 189.0/255.0, green: 203.0/255.0, blue: 215.0/255.0, alpha: 1.0).cgColor
        case .notes:
            self.layer?.backgroundColor = NSColor(red: 239.0/255.0, green: 203.0/255.0, blue: 75.0/255.0, alpha: 1.0).cgColor
            
            let slidePadding = min(self.frame.height, self.frame.width) * 0.2
            let barHeight = (self.frame.height - 2 * slidePadding) * 0.2
            let barWidth = self.frame.width - 2 * slidePadding
            
            let bar1 = CAShapeLayer()
            bar1.cornerRadius = barHeight/2
            bar1.frame = CGRect(x: slidePadding, y: slidePadding, width: barWidth * 0.8, height: barHeight)
            bar1.backgroundColor = NSColor.white.cgColor
            
            let bar2 = CAShapeLayer()
            bar2.cornerRadius = barHeight/2
            bar2.frame = CGRect(x: slidePadding, y: slidePadding + 2 * barHeight, width: barWidth, height: barHeight)
            bar2.backgroundColor = NSColor.white.cgColor
            
            let bar3 = CAShapeLayer()
            bar3.cornerRadius = barHeight/2
            bar3.frame = CGRect(x: slidePadding, y: slidePadding + 4 * barHeight, width: barWidth, height: barHeight)
            bar3.backgroundColor = NSColor.white.cgColor
            
            self.layer?.addSublayer(bar1)
            self.layer?.addSublayer(bar2)
            self.layer?.addSublayer(bar3)
            
        default:
            break
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        if isDraggable {
            // Start dragging session
            if let slideType = self.type?.rawValue {
                // Setup pasteboard item
                let pasteboardItem = NSPasteboardItem()
                pasteboardItem.setString(slideType, forType: .slideType)
                let draggingItem = NSDraggingItem(pasteboardWriter: pasteboardItem)
                
                // Create dragging item
                let draggingImage = self.image()
                draggingItem.setDraggingFrame(self.bounds, contents: draggingImage)
                
                beginDraggingSession(with: [draggingItem], event: event, source: self)
            }
        }
    }
}


extension SlideSymbolView: NSDraggingSource {
    
    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        switch (context) {
        case .outsideApplication:
            return NSDragOperation()
        case .withinApplication:
            return .generic
        @unknown default:
            return NSDragOperation()
        }
    }
}
