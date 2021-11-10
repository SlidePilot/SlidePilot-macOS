//
//  LayoutSlideView.swift
//  SlidePilot
//
//  Created by Pascal Braband on 10.11.21.
//  Copyright © 2021 Pascal Braband. All rights reserved.
//

import Cocoa

class LayoutSlideView: NSView {
    
    private var isReceivingDrag = false {
        didSet {
            highlightView.isHighlighted = self.isReceivingDrag
        }
    }
    
    private var slideSymbol: SlideSymbolView!
    private var highlightView: LayoutSlideHighlightView!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        registerForDraggedTypes([.slideType])
        
        // Add SlideSymbolView
        slideSymbol = SlideSymbolView(type: nil)
        slideSymbol.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(slideSymbol)
        self.addConstraints([
            NSLayoutConstraint(item: slideSymbol!, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: slideSymbol!, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: slideSymbol!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: slideSymbol!, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0),
        ])
        
        // Add highlight view (above SlideSymbolView)
        highlightView = LayoutSlideHighlightView(frame: .zero)
        highlightView.wantsLayer = true
        highlightView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints([
            NSLayoutConstraint(item: highlightView!, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: highlightView!, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: highlightView!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: highlightView!, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0),
        ])
        self.addSubview(highlightView)
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let cornerRadius = min(self.frame.width, self.frame.height) * 0.2
        self.layer?.backgroundColor = NSColor(white: 0.85, alpha: 1.0).cgColor
        self.layer?.cornerRadius = cornerRadius
    }
    
    
    // MARK: - Dragging
    
    func shouldAllowDragging(_ draggingInfo: NSDraggingInfo) -> Bool {
        if let types = draggingInfo.draggingPasteboard.types,
           types.contains(.slideType) {
            return true
        } else {
            return false
        }
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let allow = shouldAllowDragging(sender)
        isReceivingDrag = allow
        return allow ? .move : NSDragOperation()
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        isReceivingDrag = false
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        isReceivingDrag = false
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return shouldAllowDragging(sender)
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        isReceivingDrag = false
        
        // Get slide type from pasteboard and display corresponding type in SlideSymbolView
        if let slideTypeRaw = sender.draggingPasteboard.string(forType: .slideType),
           let slideType = SlideType(rawValue: slideTypeRaw) {
            slideSymbol.type = slideType
            return true
        } else {
            return false
        }
    }
}


class LayoutSlideHighlightView: NSView {
    
    var isHighlighted: Bool = false {
        didSet {
            needsDisplay = true
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let cornerRadius = min(self.frame.width, self.frame.height) * 0.2
        
        if isHighlighted {
            // Draw highlight if selected
            NSColor.selectedControlColor.set()
            let lineWidth: CGFloat = 10.0
            let path = NSBezierPath(roundedRect: self.bounds, xRadius: cornerRadius, yRadius: cornerRadius)
            path.lineWidth = lineWidth
            path.stroke()
        } else {
            // Otherwise draw normal border
            NSColor(white: 0.75, alpha: 1.0).set()
            let path = NSBezierPath(roundedRect: self.bounds, xRadius: cornerRadius, yRadius: cornerRadius)
            path.lineWidth = 5
            path.stroke()
        }
    }
}
