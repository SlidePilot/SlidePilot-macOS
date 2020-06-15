//
//  Drawing.swift
//  SlidePilot
//
//  Created by Pascal Braband on 15.06.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class Drawing: NSObject {
    private(set) var lines = [Line]()
    private(set) var backgroundColor: NSColor = .clear
    
    private var undoManager: UndoManager? {
        return NSApp.mainWindow?.undoManager
    }
    
    
    /**
     Adds a new line to the line drawing. Registers change in UndoManager
     
     - parameters:
        - line: The Line object to be added to the drawing.
     */
    func add(line: Line) {
        var newLines = lines
        newLines.append(line)
        setLines(to: newLines)
    }
    
    
    private var cachedLines: [Line]?
    
    /**
     Updates lines array for this drawing. Registers change in UndoManager.
     
     - parameters:
        - newLines: The new Line array.
     */
    @objc private func setLines(to newLines: [Line]) {
        cachedLines = lines
        lines = newLines
        
        undoManager?.registerUndo(withTarget: self, selector: #selector(setLines(to:)), object: cachedLines)
        
        CanvasController.didChangeDrawing(to: self, sender: self)
    }
    
    
    /**
     Clears the drawing. This means all lines are deleted. Registers change in UndoManager
     */
    @objc func clear() {
        setLines(to: [Line]())
    }
    
    
    private var cachedBackgroundColor: NSColor?
    
    /**
     Sets the background color of the drawing. Registers change in UndoManager.
     
     - parameters:
        - newColor: The new background color for the drawing.
        - shouldClearLines: If this is set to true, the lines in the drawing will be cleared. Setting the background color and clearing the lines will be grouped into one undo operation.
     */
    func setBackgroundColor(to newColor: NSColor, shouldClearLines: Bool) {
        undoManager?.beginUndoGrouping()
        if shouldClearLines {
            clear()
        }
        
        setBackgroundColor(to: newColor)
        
        undoManager?.endUndoGrouping()
    }
    
    
    @objc private func setBackgroundColor(to newColor: NSColor) {
        cachedBackgroundColor = backgroundColor
        backgroundColor = newColor
        undoManager?.registerUndo(withTarget: self, selector: #selector(setBackgroundColor(to:)), object: cachedBackgroundColor)
        
        CanvasController.didChangeCanvasBackground(sender: self)
    }
}




class Line: NSObject {
    var components = [CGPoint]()
    var color: NSColor = .black
    var frame: CGRect
    
    init(color: NSColor, frame: CGRect) {
        self.color = color
        self.frame = frame
    }
    
    
    /**
     Adds a point to the line with relative coordinates. Meaning the relative position of the `newPoint` in the `frame`.
     */
    func add(_ newPoint: CGPoint) {
        components.append(CGPoint(x: newPoint.x / frame.width, y: newPoint.y / frame.height))
    }
    
    
    func getAbsolutePoints(in targetFrame: CGRect) -> [CGPoint] {
        return components.map { (p) -> CGPoint in
            return CGPoint(x: p.x * targetFrame.width, y: p.y * targetFrame.height)
        }
    }
}
