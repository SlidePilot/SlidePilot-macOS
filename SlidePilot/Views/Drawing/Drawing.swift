//
//  Drawing.swift
//  SlidePilot
//
//  Created by Pascal Braband on 15.06.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class Drawing: NSObject, NSCopying {
    private(set) var lines = [Line]()
    private(set) var backgroundColor: NSColor = .clear
    
    
    override init() { }
    
    
    init(lines: [Line], backgroundColor: NSColor) {
        self.lines = lines
        self.backgroundColor = backgroundColor
    }
    
    
    /**
     Adds a new line to the line drawing.
     
     - parameters:
        - line: The `Line` object to be added to the drawing.
     */
    func add(line: Line) {
        lines.append(line)
    }
    
    
    /**
     Clears the drawing. This means all lines are deleted.
     */
    @objc func clear() {
        // Only clear if not already empty
        guard lines.count > 0 else { return }
        lines = [Line]()
    }
    
    
    /**
     Sets the background color of the drawing.
     
     - parameters:
        - newColor: The new background color for the drawing.
        - shouldClearLines: If this is set to `true`, the lines in the drawing will be cleared. Setting the background color and clearing the lines will be grouped into one undo operation.
     */
    func setBackgroundColor(to newColor: NSColor, shouldClearLines: Bool) {
        if shouldClearLines {
            clear()
        }
        
        backgroundColor = newColor
    }
    
    
    func copy(with zone: NSZone? = nil) -> Any {
        let backgroundColorCopy: NSColor = self.backgroundColor.copy() as? NSColor ?? .clear
        return Drawing(lines: self.lines, backgroundColor: backgroundColorCopy)
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
