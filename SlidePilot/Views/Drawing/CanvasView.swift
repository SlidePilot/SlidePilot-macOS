//
//  CanvasView.swift
//  SlidePilot
//
//  Created by Pascal Braband on 15.06.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class CanvasView: NSView {
    
    var allowsDrawing = true
    var drawing: Drawing! {
        didSet {
            self.needsDisplay = true
        }
    }
    
    private var currentLine: Line?
    
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    
    func setup() {
        CanvasController.subscribeDrawingChanged(target: self, action: #selector(didChangeDrawing(_:)))
        CanvasController.subscribeDrawingColorChanged(target: self, action: #selector(didChangeDrawingColor(_:)))
        CanvasController.subscribeCanvasBackgroundChanged(target: self, action: #selector(didChangeCanvasBackground(_:)))
        CanvasController.subscribeClearCanvas(target: self, action: #selector(didClearCanvas(_:)))
        
        // Either grab display the current drawing or start with a new one
        self.drawing = DocumentController.drawings[PageController.currentPage] ?? Drawing()
    }
    

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let context = NSGraphicsContext.current?.cgContext
        
        context?.setFillColor(drawing.backgroundColor.cgColor)
        context?.fill(self.bounds)

        // Draw all lines from the drawing
        for line in drawing.lines {
            context?.beginPath()
            let linePoints = line.getAbsolutePoints(in: self.frame)
            guard linePoints.count > 0 else { continue }
            
            context?.move(to: linePoints.first!)
            for component in linePoints.dropFirst()  {
                context?.addLine(to: component)
                context?.move(to: component)
            }
            context?.setStrokeColor(line.color.cgColor)
            context?.setLineWidth(2.0)
            context?.strokePath()
        }
    }
    
    
    override func mouseDown(with event: NSEvent) {
        guard allowsDrawing else { super.mouseUp(with: event); return }
        
        // Add a new line
        currentLine = Line(color: CanvasController.drawingColor, frame: self.frame)
        guard let newPoint = self.window?.contentView?.convert(event.locationInWindow, to: self) else { return }
        currentLine?.add(newPoint)
        drawing.add(line: currentLine!)
    }
    
    
    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        
        guard allowsDrawing else { super.mouseDragged(with: event); return }
        
        // Add new point to currentLine
        guard let newPoint = self.window?.contentView?.convert(event.locationInWindow, to: self) else { return }
        currentLine?.add(newPoint)
        
        self.needsDisplay = true
        CanvasController.didChangeDrawing(to: drawing, sender: self)
    }
    
    
    private func updateCanvas() {
        self.drawing = CanvasController.drawing
        self.needsDisplay = true
    }
    
    
    
    
    // MARK: Control Handlers
    
    override func removeFromSuperview() {
        if !DisplayController.areDrawingToolsDisplayed {
            self.undoManager?.removeAllActions()
        }
        super.removeFromSuperview()
    }
    
    
    @objc func didChangeDrawing(_ notification: Notification) {
        updateCanvas()
    }
    
    
    @objc func didChangeDrawingColor(_ notification: Notification) {
    }
    
    
    @objc func didChangeCanvasBackground(_ notification: Notification) {
        updateCanvas()
    }
    
    
    @objc func didClearCanvas(_ notification: Notification) {
        updateCanvas()
    }
}
