//
//  Drawing.swift
//  SlidePilot
//
//  Created by Pascal Braband on 15.06.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class Drawing: NSObject, NSCopying {
    
    /// The frame, that the drawing resides in.
    private(set) var frame: CGRect!
    
    /// An array of lines, that make up the drawing.
    private(set) var lines = [Line]()
    
    // The background color of the drawing.
    private(set) var backgroundColor: NSColor = .clear
    
    
    /// - Parameters:
    ///     - frame: The frame, that the drawing resides in
    init(frame: CGRect = .zero) {
        self.frame = frame
    }
    
    
    private init(frame: CGRect, lines: [Line], backgroundColor: NSColor) {
        self.frame = frame
        self.lines = lines
        self.backgroundColor = backgroundColor
    }
    
    
    /// Adds a new line to the drawing.
    ///
    /// - Parameters:
    ///     - color: The color that the line should have.
    ///
    /// - Returns: The `Line` object that was added to the drawing.
    ///
    func addLine(color: NSColor) -> Line {
        let newLine = Line(drawing: self, color: color)
        lines.append(newLine)
        return newLine
    }
    
    
    /// Clears the drawing. This means all lines are deleted.
    @objc func clear() {
        // Only clear if not already empty
        guard lines.count > 0 else { return }
        lines = [Line]()
    }
    
    
    /// Sets the background color of the drawing.
    ///
    /// - Parameters:
    ///     - newColor: The new background color for the drawing.
    ///     - shouldClearLines: If this is set to `true`, the lines in the drawing will be cleared. Setting the background color and clearing the lines will be grouped into one undo operation.
    func setBackgroundColor(to newColor: NSColor, shouldClearLines: Bool) {
        if shouldClearLines {
            clear()
        }
        
        backgroundColor = newColor
    }
    
    
    func copy(with zone: NSZone? = nil) -> Any {
        // Copy the object
        let backgroundColorCopy: NSColor = self.backgroundColor.copy() as? NSColor ?? .clear
        let newDrawing = Drawing(frame: self.frame, lines: [Line](), backgroundColor: backgroundColorCopy)
        
        // Copy every line and set the new drawing to be its parent
        let lines = self.lines.map { (line) -> Line in Line(components: line.components, drawing: newDrawing, color: line.color) }
        newDrawing.lines = lines
        
        return newDrawing
    }
}




/// Represents a line in a `Drawing`.
///
/// Terms:
/// - drawingFrame: The frame, that the drawing resides in.
/// - drawingSection: A section of the `drawingFrame`, that may be equal to the drawing.
/// - canvasFrame: A projection of the `drawingSection` to a view in a window. This means the `canvasFrame` represents the same section of the drawing as `drawingSection` does, but it may be a different size as the `canvasFrame` is exactly the frame, that is displayed to the user in a view.
///
class Line: NSObject {
    var components = [CGPoint]()
    var color: NSColor = .black
    weak var drawing: Drawing?
    
    fileprivate init(drawing: Drawing, color: NSColor) {
        self.drawing = drawing
        self.color = color
    }
    
    fileprivate init(components: [CGPoint], drawing: Drawing, color: NSColor) {
        self.components = components
        self.drawing = drawing
        self.color = color
    }
    
    
    /// Adds a point to the line with relative coordinates.
    ///
    /// The relative coordinates are calculated, by using the `drawingFrame`, `drawingSection` and `canvasFrame`. First the point is translated from the `canvasFrame` (which is a projection of `drawingSection`) to the `drawingSection`. Then the relative coordinates in the `drawingFrame` are calculated.
    ///
    /// - Parameters:
    ///     - newPoint: The point to be added. This point lives inside of `canvasFrame`.
    ///     - canvasFrame: The frame of the view, that the `newPoint` lives in.
    ///     - drawingSection: The section of the drawing, that the `canvasFrame` displays.
    func add(_ newPoint: CGPoint, canvasFrame: CGRect, drawingSection: CGRect) {
        guard let drawingFrame = drawing?.frame else { return }
        
        // First calculate relative point in canvasFrame. This equals to the relative coordinate in drawingSection
        let relativePointInSection = CGPoint(x: newPoint.x / canvasFrame.width, y: newPoint.y / canvasFrame.height)
        
        // Then translate the relative point from drawingSection to drawingFrame
        let translation = getTranslationRatio(parent: drawingFrame, section: drawingSection)
        
        // Calculate relative point with the following formula, with drawingFrame (df), drawingSection (ds), relativePoint (p), translation (tl)
        // (ds / df) + (p / tl)
        let relativePoint = CGPoint(
            x: (drawingSection.minX / drawingFrame.width) + (relativePointInSection.x / translation.width),
            y: (drawingSection.minY / drawingFrame.height) + (relativePointInSection.y / translation.height))
        
        components.append(relativePoint)
    }
    
    
    /// Calculates the absolute coordinates for the line in a given frame.
    ///
    /// - Parameters:
    ///     - canvasFrame: The projection of `drawingSection`, in which the line points should be translated
    ///     - drawingSection: The section of the drawing, that the `canvasFrame` displays.
    ///
    func getAbsolutePoints(in canvasFrame: CGRect, drawingSection: CGRect) -> [CGPoint]? {
        guard let drawingFrame = drawing?.frame else { return nil }
        
        let translation = getTranslationRatio(parent: drawingFrame, section: drawingSection)
        
        return components.map { (p) -> CGPoint in
            // Calculate relative point in section from relative point in drawing (p)
            // (p - ds / df) * tl
            let relativePointInSection = CGPoint(
                x: (p.x - drawingSection.minX / drawingFrame.width) * translation.width,
                y: (p.y - drawingSection.minY / drawingFrame.height) * translation.height)
            
            // Translate relative coordinate to absolute coordinate in target frame
            return CGPoint(
                x: relativePointInSection.x * canvasFrame.width,
                y: relativePointInSection.y * canvasFrame.height)
        }
    }
    
    
    /// Calculates the translation ratio between a parent frame and a section of that frame.
    ///
    /// - Parameters:
    ///     - parent: The parent frame.
    ///     - section: A section of the parent frame.
    ///
    /// - Returns: The ratio between parent and section of the parent.
    private func getTranslationRatio(parent: CGRect, section: CGRect) -> CGSize {
        let translation = CGSize(
            width: parent.width / section.width,
            height: parent.height / section.height)
        
        return translation
    }
    
    
    /// Converts the `Line` object to an `NSBezierPath`
    ///
    /// - Parameters:
    ///     - canvasFrame: The projection of `drawingSection`, in which the line points should be translated
    ///     - drawingSection: The section of the drawing, that the `canvasFrame` displays.
    ///
    /// - Returns: An optional `NSBezierPath`, created from the `Line` object.
    func getBezierPath(in canvasFrame: CGRect, drawingSection: CGRect) -> NSBezierPath? {
        let path = NSBezierPath()
        guard let coordinates = getAbsolutePoints(in: canvasFrame, drawingSection: drawingSection) else { return nil }
        
        // Check that there is at least one point for that line
        guard coordinates.count > 0 else { return nil }
        
        // Create path by iterating over components
        path.move(to: coordinates[0])
        for point in coordinates {
            path.line(to: point)
        }
        
        return path
    }

}
