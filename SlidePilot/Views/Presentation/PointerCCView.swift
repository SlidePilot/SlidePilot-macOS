//
//  PointerCCView.swift
//  SlidePilot
//
//  Created by Pascal Braband on 15.10.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//
//  Every Pointer is drawn in a separate container layer, so that it can be easily removed

import Cocoa

class PointerCCView: NSView {
    
    enum Shape: Int, Codable {
        case target, dot, circle, plus, cross, square, cursor, hand
    }
    
    struct Configuration: Codable, Equatable {
        var shape: Shape
        var size: CGFloat?
        var thickness: CGFloat?
        var color: NSColor?
        var borderWidth: CGFloat?
        var borderColor: NSColor?
        var shadowWidth: CGFloat?
        
        enum CodingKeys: String, CodingKey {
            case shape, size, thickness, color, borderWidth, borderColor, shadowWidth
        }
        
        init(shape: Shape, size: CGFloat? = nil, thickness: CGFloat? = nil, color: NSColor? = nil, borderWidth: CGFloat? = nil, borderColor: NSColor? = nil, shadowWidth: CGFloat? = nil) {
            self.shape = shape
            self.size = size
            self.thickness = thickness
            self.color = color
            self.borderWidth = borderWidth
            self.borderColor = borderColor
            self.shadowWidth = shadowWidth
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            shape = try values.decode(Shape.self, forKey: .shape)
            size = try values.decode(CGFloat?.self, forKey: .size)
            thickness = try values.decode(CGFloat?.self, forKey: .thickness)
            borderWidth = try values.decode(CGFloat?.self, forKey: .borderWidth)
            shadowWidth = try values.decode(CGFloat?.self, forKey: .shadowWidth)
            
            // Decode Colors
            if let colorData = try values.decode(Data?.self, forKey: .color) {
                color = NSKeyedUnarchiver.unarchive(data: colorData, of: NSColor.self)
            }
            if let borderColorData = try values.decode(Data?.self, forKey: .borderColor) {
                borderColor = NSKeyedUnarchiver.unarchive(data: borderColorData, of: NSColor.self)
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(shape, forKey: .shape)
            try container.encode(size, forKey: .size)
            try container.encode(thickness, forKey: .thickness)
            try container.encode(borderWidth, forKey: .borderWidth)
            try container.encode(shadowWidth, forKey: .shadowWidth)
            
            let colorData = NSKeyedArchiver.archive(object: color)
            try container.encode(colorData, forKey: .color)
            let borderColorData = NSKeyedArchiver.archive(object: borderColor)
            try container.encode(borderColorData, forKey: .borderColor)
        }
    }
    
    // Default configurations
    static let cursor = Configuration(shape: .cursor)
    static let hand = Configuration(shape: .hand)
    static let target = Configuration(shape: .target, size: 44, thickness: 3, color: .black, borderWidth: 2, borderColor: .white, shadowWidth: 0)
    static let targetColor = Configuration(shape: .target, size: 44, thickness: 3, color: .systemRed, shadowWidth: 0)
    static let circle = Configuration(shape: .circle, size: 20, thickness: 3, color: .white, shadowWidth: 10)
    static let dot = Configuration(shape: .dot, size: 10, color: .black, borderWidth: 5, borderColor: .white, shadowWidth: 10)
    
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
    var shadowWidth: CGFloat = 0.0 {
        didSet { self.needsDisplay = true } }
    
    var configuration: Configuration {
        return Configuration(shape: shape, size: size, thickness: thickness, color: color, borderWidth: borderWidth, borderColor: borderColor, shadowWidth: shadowWidth)
    }
    
    /** The position of the pointers hotspot (the spot where interactions are taken). */
    var hotspot: CGPoint = CGPoint(x: 0, y: 0)
    
    /** The position, that the pointer needs to be shifted to be centered at hotspot*/
    var hotspotShift: CGPoint = CGPoint(x: 0, y: 0)
    
    
    
    
    // MARK: - Initializer
    
    init(configuration: Configuration) {
        super.init(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        load(configuration)
    }
    
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    public func load(_ configuration: Configuration) {
        self.shape = configuration.shape
        self.size = configuration.size ?? 0.0
        self.thickness = configuration.thickness ?? 0.0
        self.color = configuration.color ?? .black
        self.borderWidth = configuration.borderWidth ?? 0.0
        self.borderColor = configuration.borderColor ?? .black
        self.shadowWidth = configuration.shadowWidth ?? 0.0
    }
    
    
    
    
    // MARK: Drawing
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.layer?.masksToBounds = false
        
        self.layer?.autoresizingMask = CAAutoresizingMask(arrayLiteral: [.layerWidthSizable, .layerHeightSizable])

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
        case .cursor:
            drawCursor()
        case .hand:
            drawHand()
        }
    }
    
    
    private func drawTarget() {
        // Calculate frame size
        self.frame.size = CGSize(width: size+thickness+borderWidth, height: size+thickness+borderWidth)
        self.layer?.frame = self.frame
        hotspot = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        hotspotShift = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        
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
        
        let containerLayer = CALayer()
        if borderWidth != 0 { containerLayer.addSublayer(centerCircleBorder) }
        containerLayer.addSublayer(centerCircle)
        containerLayer.addSublayer(outerCircleBorder)
        containerLayer.addSublayer(outerCircle)
        self.layer?.addSublayer(containerLayer)
        
        drawShaddow(on: containerLayer)
    }
    
    
    private func drawDot() {
        // Calculate frame size
        self.frame.size = CGSize(width: size+borderWidth, height: size+borderWidth)
        self.layer?.frame = self.frame
        hotspot = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        hotspotShift = hotspot
        
        let dot = CAShapeLayer()
        let dotFrame = CGRect(x: borderWidth/2, y: borderWidth/2, width: size, height: size)
        dot.path = CGPath(ellipseIn: dotFrame, transform: nil)
        dot.fillColor = color.cgColor
        
        let dotBorder = CAShapeLayer()
        let dotBorderFrame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        dotBorder.path = CGPath(ellipseIn: dotBorderFrame, transform: nil)
        dotBorder.fillColor = borderColor.cgColor
        
        let containerLayer = CALayer()
        if borderWidth != 0 { containerLayer.addSublayer(dotBorder) }
        containerLayer.addSublayer(dot)
        self.layer?.addSublayer(containerLayer)
        
        drawShaddow(on: containerLayer)
    }
    
    
    private func drawCircle() {
        // Calculate frame size
        self.frame.size = CGSize(width: size+thickness+borderWidth, height: size+thickness+borderWidth)
        self.layer?.frame = self.frame
        hotspot = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        hotspotShift = hotspot
        
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
        
        let containerLayer = CALayer()
        containerLayer.addSublayer(circleBorder)
        containerLayer.addSublayer(circle)
        self.layer?.addSublayer(containerLayer)
        
        drawShaddow(on: containerLayer)
    }
    
    
    private func drawPlus() {
        self.frame.size = CGSize(width: size+borderWidth, height: size+borderWidth)
        self.layer?.frame = self.frame
        hotspot = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        hotspotShift = hotspot
        
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
        
        let containerLayer = CALayer()
        if borderWidth != 0 { containerLayer.addSublayer(verticalBarBorder) }
        if borderWidth != 0 { containerLayer.addSublayer(horizontalBarBorder) }
        containerLayer.addSublayer(verticalBar)
        containerLayer.addSublayer(horizontalBar)
        self.layer?.addSublayer(containerLayer)
        
        drawShaddow(on: containerLayer)
    }
    
    
    private func drawCross() {
        self.frame.size = CGSize(width: size+borderWidth, height: size+borderWidth)
        self.layer?.frame = self.frame
        hotspot = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        hotspotShift = hotspot
        
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
        
        let containerLayer = CALayer()
        containerLayer.frame = self.bounds
        if borderWidth != 0 { containerLayer.addSublayer(verticalBarBorder) }
        if borderWidth != 0 { containerLayer.addSublayer(horizontalBarBorder) }
        containerLayer.addSublayer(verticalBar)
        containerLayer.addSublayer(horizontalBar)
        
        containerLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        containerLayer.transform = CATransform3DRotate(CATransform3DIdentity, 45.0/180.0*CGFloat.pi, 0, 0, 1)
        
        self.layer?.addSublayer(containerLayer)
        
        drawShaddow(on: containerLayer)
    }
    
    
    private func drawSquare() {
        // Calculate frame size
        self.frame.size = CGSize(width: size+borderWidth, height: size+borderWidth)
        self.layer?.frame = self.frame
        hotspot = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        hotspotShift = hotspot
        
        let square = CAShapeLayer()
        let squareFrame = CGRect(x: borderWidth/2, y: borderWidth/2, width: size, height: size)
        square.path = CGPath(rect: squareFrame, transform: nil)
        square.fillColor = color.cgColor
        
        let squareBorder = CAShapeLayer()
        let squareBorderFrame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        squareBorder.path = CGPath(rect: squareBorderFrame, transform: nil)
        squareBorder.fillColor = borderColor.cgColor
        
        let containerLayer = CALayer()
        if borderWidth != 0 { containerLayer.addSublayer(squareBorder) }
        containerLayer.addSublayer(square)
        self.layer?.addSublayer(containerLayer)
        
        drawShaddow(on: containerLayer)
    }
    
    
    private func drawShaddow(on layer: CALayer) {
        if shadowWidth > 0 {
            layer.shadowOpacity = 1.0
            layer.shadowColor = .black
            layer.shadowOffset = NSMakeSize(0, 0)
            layer.shadowRadius = shadowWidth
        } else {
            layer.shadowOpacity = 0.0
        }
    }
    
    
    private func drawCursor() {
        draw(with: NSCursor.arrow.image)
        hotspot = NSCursor.arrow.hotSpot
        hotspotShift = NSPoint(x: 4, y: NSCursor.arrow.image.size.height-4)
    }
    
    
    private func drawHand() {
        draw(with: NSCursor.pointingHand.image)
        hotspot = NSCursor.pointingHand.hotSpot
        hotspotShift = NSPoint(x: 4, y: NSCursor.pointingHand.image.size.height-4)
    }
    
    
    private func draw(with image: NSImage) {
        self.frame.size = image.size
        self.layer?.frame = self.frame
        
        let imageLayer = CALayer()
        imageLayer.frame = self.bounds
        imageLayer.contents = image
        self.layer?.addSublayer(imageLayer)
    }
    
    
    
    
    // MARK: - Misc
    
    public func setPosition(_ position: NSPoint) {
        self.frame.origin = NSPoint(x: position.x-self.hotspot.x,
                                    y: position.y-self.hotspot.y)
    }
    
    
    public func image() -> NSImage {
        let imageRepresentation = bitmapImageRepForCachingDisplay(in: bounds)!
        cacheDisplay(in: bounds, to: imageRepresentation)
        return NSImage(cgImage: imageRepresentation.cgImage!, size: bounds.size)
    }
}
