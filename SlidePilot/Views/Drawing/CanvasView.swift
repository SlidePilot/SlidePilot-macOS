//
//  CanvasView.swift
//  SlidePilot
//
//  Created by Pascal Braband on 16.02.22.
//  Copyright © 2022 Pascal Braband. All rights reserved.
//

import Cocoa

class CanvasView: NSView {
    
    var delegate: CanvasViewDelegate?
    
    /// The drawing object, that this view shows and that may be modified by this view.
    var drawing: Drawing! {
        didSet {
            self.needsDisplay = true
        }
    }
    
    private var cachedDrawing: Drawing?
    
    /// Controls whether the drawing may be modified using the mouse.
    var allowsDrawing = true
    
    /// The line that is currently drawn, while mouse is dragged.
    private var currentLine: Line?
    
    private var drawingSection: CGRect? {
        guard let currentPage = DocumentController.document?.page(at: PageController.currentPage) else { return nil }
        return DisplayController.notesPosition.displayModeForPresentation().getBounds(for: currentPage)
    }
    
    
    init(drawing: Drawing) {
        super.init(frame: .zero)
        self.drawing = drawing
    }
    
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.drawing = Drawing()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.drawing = Drawing()
    }
    

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        
        context.setFillColor(drawing.backgroundColor.cgColor)
        context.fill(self.bounds)

        // Draw all lines from the drawing
        for line in drawing.lines {
            context.beginPath()
            guard let drawingSection = self.drawingSection else { return }
            guard let linePoints = line.getAbsolutePoints(in: self.frame, drawingSection: drawingSection) else { continue }
            guard linePoints.count > 0 else { continue }
            
            context.move(to: linePoints.first!)
            for component in linePoints.dropFirst()  {
                context.addLine(to: component)
                context.move(to: component)
            }
            context.setStrokeColor(line.color.cgColor)
            context.setLineWidth(2.0)
            context.strokePath()
        }
    }
    
    
    override func mouseDown(with event: NSEvent) {
        guard allowsDrawing else { super.mouseDown(with: event); return }

        // Add new line to drawing
        let newDrawing = drawing.copy() as! Drawing
        currentLine = newDrawing.addLine(color: CanvasController.drawingColor)
        setDrawing(to: newDrawing)
        
        // Add first point to line
        guard let newPoint = self.window?.contentView?.convert(event.locationInWindow, to: self) else { return }
        guard let drawingSection = self.drawingSection else { return }
        currentLine?.add(newPoint, canvasFrame: self.frame, drawingSection: drawingSection)
        
        delegate?.drawingDidChange(drawing)
    }
    
    
    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        
        guard allowsDrawing else { super.mouseDragged(with: event); return }
        
        // Add new point to currentLine
        guard let newPoint = self.window?.contentView?.convert(event.locationInWindow, to: self) else { return }
        guard let drawingSection = self.drawingSection else { return }
        currentLine?.add(newPoint, canvasFrame: self.frame, drawingSection: drawingSection)
        
        self.needsDisplay = true
        
        delegate?.drawingDidChange(drawing)
    }
    
    
    private func updateCanvas() {
        self.needsDisplay = true
    }
    
    
    @objc private func setDrawing(to newDrawing: Drawing) {
        cachedDrawing = drawing
        drawing = newDrawing
        
        undoManager?.registerUndo(withTarget: self, selector: #selector(setDrawing(to:)), object: cachedDrawing)
        delegate?.drawingDidChange(drawing)
    }
    
    
    
    
    // MARK: Control Handlers
    
    override func removeFromSuperview() {
        self.undoManager?.removeAllActions()
        super.removeFromSuperview()
    }
    
    
    /// Sets the background color of the drawing
    func setBackgroundColor(to backgroundColor: NSColor) {
        // Update drawing
        let newDrawing = drawing.copy() as! Drawing
        newDrawing.setBackgroundColor(to: backgroundColor, shouldClearLines: true)
        setDrawing(to: newDrawing)
        
        // Update canvas and notify delegate
        updateCanvas()
        delegate?.drawingDidChange(drawing)
    }
    
    
    /// Removes all lines from the drawing
    func clearCanvas() {
        // Update drawing
        let newDrawing = drawing.copy() as! Drawing
        newDrawing.clear()
        setDrawing(to: newDrawing)
        
        // Update canvas and notify delegate
        updateCanvas()
        delegate?.drawingDidChange(drawing)
    }
}




protocol CanvasViewDelegate {
    func drawingDidChange(_ drawing: Drawing)
}
