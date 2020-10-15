//
//  PointerCCView.swift
//  SlidePilot
//
//  Created by Pascal Braband on 15.10.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class PointerCCView: NSView {
    
    enum Shape {
        case target, dot, circle, plus, cross, square
    }
    
    struct Configuration {
        var shape: Shape
        var size: CGFloat = 0.0
        var thickness: CGFloat = 0.0
        var color: NSColor = .black
        var borderWidth: CGFloat = 0.0
        var borderColor: NSColor = .black
    }
    
    var shape: Shape = .target {
        didSet { self.needsDisplay = true } }
    var size: CGFloat = 10.0 {
        didSet { self.needsDisplay = true } }
    var thickness: CGFloat = 0.0 {
        didSet { self.needsDisplay = true } }
    var color: NSColor = .black {
        didSet { self.needsDisplay = true } }
    var borderWidth: CGFloat = 0.0 {
        didSet { self.needsDisplay = true } }
    var borderColor: NSColor = .black {
        didSet { self.needsDisplay = true } }
    
    var configuration: Configuration {
        return Configuration(shape: shape, size: size, thickness: thickness, color: color, borderWidth: borderWidth, borderColor: borderColor)
    }
    
    var delegate: PointerViewChangesDelegate?
    
    
    func load(_ configuration: Configuration) {
        self.shape = configuration.shape
        self.size = configuration.size
        self.thickness = configuration.thickness
        self.color = configuration.color
        self.borderWidth = configuration.borderWidth
        self.borderColor = configuration.borderColor
    }
    
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.layer?.masksToBounds = false

        // Remove all layer
        self.layer?.sublayers?.forEach({ $0.removeFromSuperlayer() })
        
        switch shape {
        case .target:
            drawTarget()
        case .dot:
            drawDot()
        case .circle:
            drawCircle()
        case .plus:
            drawPlus()
        case .cross:
            drawCross()
        case .square:
            drawSquare()
        }
    }
    
    
    private func drawTarget() {
        // Calculate frame size
        self.frame.size = CGSize(width: size+thickness+borderWidth, height: size+thickness+borderWidth)
        delegate?.didChange(frame: self.frame)
        
        let centerCircle = CAShapeLayer()
        let centerCircleSize = thickness*1.4
        let centerCircleFrame = CGRect(x: (self.frame.width-centerCircleSize)/2, y: (self.frame.height-centerCircleSize)/2, width: centerCircleSize, height: centerCircleSize)
        centerCircle.path = CGPath(ellipseIn: centerCircleFrame, transform: nil)
        centerCircle.fillColor = color.cgColor
        
        let centerCircleBorder = CAShapeLayer()
        let centerCircleBorderFrame = CGRect(x: (self.frame.width-centerCircleSize)/2-borderWidth, y: (self.frame.height-centerCircleSize)/2-borderWidth, width: centerCircleSize+borderWidth*2, height: centerCircleSize+borderWidth*2)
        centerCircleBorder.path = CGPath(ellipseIn: centerCircleBorderFrame, transform: nil)
        centerCircleBorder.fillColor = borderColor.cgColor
        
        let outerCircle = CAShapeLayer()
        let padding = borderWidth + thickness/2
        let outerCircleFrame = CGRect(x: padding, y: padding, width: self.frame.width-padding*2, height: self.frame.height-padding*2)
        outerCircle.path = CGPath(ellipseIn: outerCircleFrame, transform: nil)
        outerCircle.fillColor = NSColor.clear.cgColor
        outerCircle.strokeColor = color.cgColor
        outerCircle.lineWidth = thickness
        
        let outerCircleBorder = CAShapeLayer()
        let borderPadding = borderWidth/2
        let outerCircleBorderFrame = CGRect(x: borderPadding, y: borderPadding, width: self.frame.width-borderPadding*2, height: self.frame.height-borderPadding*2)
        outerCircleBorder.path = CGPath(ellipseIn: outerCircleBorderFrame, transform: nil)
        outerCircleBorder.fillColor = NSColor.clear.cgColor
        outerCircleBorder.strokeColor = borderColor.cgColor
        outerCircleBorder.lineWidth = borderWidth
        
        if borderWidth != 0 { self.layer?.addSublayer(centerCircleBorder) }
        self.layer?.addSublayer(centerCircle)
        self.layer?.addSublayer(outerCircleBorder)
        self.layer?.addSublayer(outerCircle)
    }
    
    
    private func drawDot() {
        // Calculate frame size
        self.frame.size = CGSize(width: size+borderWidth, height: size+borderWidth)
        delegate?.didChange(frame: self.frame)
        
        let dot = CAShapeLayer()
        let dotFrame = CGRect(x: borderWidth/2, y: borderWidth/2, width: size, height: size)
        dot.path = CGPath(ellipseIn: dotFrame, transform: nil)
        dot.fillColor = color.cgColor
        
        let dotBorder = CAShapeLayer()
        let dotBorderFrame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        dotBorder.path = CGPath(ellipseIn: dotBorderFrame, transform: nil)
        dotBorder.fillColor = borderColor.cgColor
        
        if borderWidth != 0 { self.layer?.addSublayer(dotBorder) }
        self.layer?.addSublayer(dot)
    }
    
    
    private func drawCircle() {
        // Calculate frame size
        self.frame.size = CGSize(width: size+thickness+borderWidth, height: size+thickness+borderWidth)
        delegate?.didChange(frame: self.frame)
        
        let circle = CAShapeLayer()
        let padding = borderWidth + thickness/2
        let circleFrame = CGRect(x: padding, y: padding, width: self.frame.width-padding*2, height: self.frame.height-padding*2)
        circle.path = CGPath(ellipseIn: circleFrame, transform: nil)
        circle.fillColor = NSColor.clear.cgColor
        circle.strokeColor = color.cgColor
        circle.lineWidth = thickness
        
        let circleBorder = CAShapeLayer()
        let borderPadding = borderWidth/2
        let circleBorderFrame = CGRect(x: borderPadding, y: borderPadding, width: self.frame.width-borderPadding*2, height: self.frame.height-borderPadding*2)
        circleBorder.path = CGPath(ellipseIn: circleBorderFrame, transform: nil)
        circleBorder.fillColor = NSColor.clear.cgColor
        circleBorder.strokeColor = borderColor.cgColor
        circleBorder.lineWidth = borderWidth
        
        self.layer?.addSublayer(circleBorder)
        self.layer?.addSublayer(circle)
    }
    
    
    private func drawPlus() {
        self.frame.size = CGSize(width: size+borderWidth, height: size+borderWidth)
        delegate?.didChange(frame: self.frame)
        
        let verticalBar = CAShapeLayer()
        let verticalBarFrame = CGRect(x: (self.frame.width-thickness)/2, y: borderWidth/2, width: thickness, height: self.frame.height-borderWidth)
        verticalBar.path = CGPath(rect: verticalBarFrame, transform: nil)
        verticalBar.fillColor = color.cgColor
        
        let verticalBarBorder = CAShapeLayer()
        let verticalBarBorderFrame = CGRect(x: (self.frame.width-thickness-borderWidth)/2, y: 0, width: thickness+borderWidth, height: self.frame.height)
        verticalBarBorder.path = CGPath(rect: verticalBarBorderFrame, transform: nil)
        verticalBarBorder.fillColor = borderColor.cgColor
        
        let horizontalBar = CAShapeLayer()
        let horizontalBarFrame = CGRect(x: borderWidth/2, y: (self.frame.height-thickness)/2, width: self.frame.width-borderWidth, height: thickness)
        horizontalBar.path = CGPath(rect: horizontalBarFrame, transform: nil)
        horizontalBar.fillColor = color.cgColor
        
        let horizontalBarBorder = CAShapeLayer()
        let horizontalBarBorderFrame = CGRect(x: 0, y: (self.frame.height-thickness-borderWidth)/2, width: self.frame.width, height: thickness+borderWidth)
        horizontalBarBorder.path = CGPath(rect: horizontalBarBorderFrame, transform: nil)
        horizontalBarBorder.fillColor = borderColor.cgColor
        
        if borderWidth != 0 { self.layer?.addSublayer(verticalBarBorder) }
        if borderWidth != 0 { self.layer?.addSublayer(horizontalBarBorder) }
        self.layer?.addSublayer(verticalBar)
        self.layer?.addSublayer(horizontalBar)
    }
    
    
    private func drawCross() {
        self.frame.size = CGSize(width: size+borderWidth, height: size+borderWidth)
        delegate?.didChange(frame: self.frame)
        
        let verticalBar = CAShapeLayer()
        let verticalBarFrame = CGRect(x: (self.frame.width-thickness)/2, y: borderWidth/2, width: thickness, height: self.frame.height-borderWidth)
        verticalBar.path = CGPath(rect: verticalBarFrame, transform: nil)
        verticalBar.fillColor = color.cgColor
        
        let verticalBarBorder = CAShapeLayer()
        let verticalBarBorderFrame = CGRect(x: (self.frame.width-thickness-borderWidth)/2, y: 0, width: thickness+borderWidth, height: self.frame.height)
        verticalBarBorder.path = CGPath(rect: verticalBarBorderFrame, transform: nil)
        verticalBarBorder.fillColor = borderColor.cgColor
        
        let horizontalBar = CAShapeLayer()
        let horizontalBarFrame = CGRect(x: borderWidth/2, y: (self.frame.height-thickness)/2, width: self.frame.width-borderWidth, height: thickness)
        horizontalBar.path = CGPath(rect: horizontalBarFrame, transform: nil)
        horizontalBar.fillColor = color.cgColor
        
        let horizontalBarBorder = CAShapeLayer()
        let horizontalBarBorderFrame = CGRect(x: 0, y: (self.frame.height-thickness-borderWidth)/2, width: self.frame.width, height: thickness+borderWidth)
        horizontalBarBorder.path = CGPath(rect: horizontalBarBorderFrame, transform: nil)
        horizontalBarBorder.fillColor = borderColor.cgColor
        
        let crossLayer = CALayer()
        crossLayer.frame = self.bounds
        if borderWidth != 0 { crossLayer.addSublayer(verticalBarBorder) }
        if borderWidth != 0 { crossLayer.addSublayer(horizontalBarBorder) }
        crossLayer.addSublayer(verticalBar)
        crossLayer.addSublayer(horizontalBar)
        
        crossLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        crossLayer.transform = CATransform3DRotate(CATransform3DIdentity, 45.0/180.0*CGFloat.pi, 0, 0, 1)
        
        self.layer?.addSublayer(crossLayer)
    }
    
    
    private func drawSquare() {
        // Calculate frame size
        self.frame.size = CGSize(width: size+borderWidth, height: size+borderWidth)
        delegate?.didChange(frame: self.frame)
        
        let square = CAShapeLayer()
        let squareFrame = CGRect(x: borderWidth/2, y: borderWidth/2, width: size, height: size)
        square.path = CGPath(rect: squareFrame, transform: nil)
        square.fillColor = color.cgColor
        
        let squareBorder = CAShapeLayer()
        let squareBorderFrame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        squareBorder.path = CGPath(rect: squareBorderFrame, transform: nil)
        squareBorder.fillColor = borderColor.cgColor
        
        if borderWidth != 0 { self.layer?.addSublayer(squareBorder) }
        self.layer?.addSublayer(square)
    }
    
}




protocol PointerViewChangesDelegate {
    func didChange(frame newFrame: CGRect)
}
