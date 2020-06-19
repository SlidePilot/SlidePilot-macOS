//
//  ColorSwatchButton.swift
//  SlidePilot
//
//  Created by Pascal Braband on 09.06.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class ColorSwatchButton: NSControl {
    
    var color: NSColor = .black {
        didSet {
            self.innerLayer?.backgroundColor = color.cgColor
            self.ringLayer?.borderColor = color.cgColor
        }
    }
    
    var state: StateValue = .off {
        didSet {
            // Only animate if value did change
            if self.state != oldValue {
                animateSelection()
            }
        }
    }
    
    private var isMouseInside = false {
        didSet {
            // Only animate if value did change
            if self.isMouseInside != oldValue {
                if isMouseInside {
                    // Highlight if mouse entered
                    animateHighlight()
                } else {
                    // Remove highlight if mouse exited
                    animateDehighlight()
                }
            }
        }
    }
    
    // Appearance parameters
    private var size: CGFloat = 25.0
    private var ringWidth: CGFloat = 2.0
    
    // Animation parameters
    private let highlightAnimationDuration = 0.1
    private let ringAnimationDuration = 0.4
    
    // Animation Keys
    private let highlightAnimationKey = "highlight-animation"
    private let dehighlightAnimationKey = "dehighlight-animation"
    private let selectAnimationKey = "select-animation"
    private let deselectAnimationKey = "deselect-animation"
    
    // Layers
    private var innerLayer: CALayer?
    private var ringLayer: CALayer?
    
    
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup(with: .white)
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup(with: .white)
    }
    
    
    init(color: NSColor, size: CGFloat = 25.0, ringWidth: CGFloat = 2.0) {
        self.color = color
        self.size = size
        self.ringWidth = ringWidth
        super.init(frame: .zero)
        setup(with: color)
    }
    
    
    func setup(with color: NSColor) {
        // Setup view
        self.translatesAutoresizingMaskIntoConstraints = false
        self.wantsLayer = true
        
        // Setup layer
        self.layer?.masksToBounds = false
        
        
        // Add size
        self.addConstraints([
            NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: size),
            NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1.0, constant: 0.0)])
        self.layoutSubtreeIfNeeded()
        
        // Setup layer for ring circle
        ringLayer = CALayer()
        ringLayer!.cornerRadius = self.bounds.width / 2
        ringLayer!.backgroundColor = .clear
        ringLayer!.borderColor = self.color.cgColor
        ringLayer!.borderWidth = 0.0
        ringLayer!.frame = self.bounds
        self.layer?.addSublayer(ringLayer!)
        
        // Setup layer for inner circle
        innerLayer = CALayer()
        innerLayer!.cornerRadius = self.bounds.width / 2
        innerLayer!.backgroundColor = self.color.cgColor
        innerLayer!.frame = self.bounds
        self.layer?.addSublayer(innerLayer!)
    }
    
    
    override func mouseDown(with event: NSEvent) {
        isMouseInside = true
    }
    
    
    override func mouseUp(with event: NSEvent) {
        if isMouseInside {
            isMouseInside = false
            
            // Call target.action
            _ = target?.perform(action, with: self)
        }
    }
    
    
    override func mouseDragged(with event: NSEvent) {
        let mouseLocationInView = self.window?.contentView?.convert(event.locationInWindow, to: self)
        if self.bounds.contains(mouseLocationInView ?? .zero) {
            isMouseInside = true
        } else {
            isMouseInside = false
        }
    }
    
    
    private func animateHighlight() {
        let fromValue = color.cgColor
        let toValue: CGColor?
        if #available(OSX 10.14, *) {
            toValue = NSColor(cgColor: color.cgColor)?.withSystemEffect(.pressed).cgColor
        } else {
            toValue = color.blended(withFraction: 0.15, of: .black)?.cgColor
        }
        let animationDuration = highlightAnimationDuration
        
        let innerAnimation = CABasicAnimation(keyPath: "backgroundColor")
        innerAnimation.duration = animationDuration
        innerLayer?.backgroundColor = toValue
        innerAnimation.fromValue = fromValue
        self.innerLayer?.add(innerAnimation, forKey: highlightAnimationKey)
        
        let ringAnimation = CABasicAnimation(keyPath: "borderColor")
        ringAnimation.duration = animationDuration
        ringLayer?.borderColor = toValue
        ringAnimation.fromValue = fromValue
        self.ringLayer?.add(ringAnimation, forKey: highlightAnimationKey)
    }
    
    
    private func animateDehighlight() {
        let fromValue: CGColor?
        if #available(OSX 10.14, *) {
            fromValue = NSColor(cgColor: color.cgColor)?.withSystemEffect(.pressed).cgColor
        } else {
            fromValue = color.blended(withFraction: 0.15, of: .black)?.cgColor
        }
        let toValue = color.cgColor
        let animationDuration = highlightAnimationDuration
        
        let innerAnimation = CABasicAnimation(keyPath: "backgroundColor")
        innerAnimation.duration = animationDuration
        innerLayer?.backgroundColor = toValue
        innerAnimation.fromValue = fromValue
        self.innerLayer?.add(innerAnimation, forKey: dehighlightAnimationKey)
        
        let ringAnimation = CABasicAnimation(keyPath: "borderColor")
        ringAnimation.duration = animationDuration
        ringLayer?.borderColor = toValue
        ringAnimation.fromValue = fromValue
        self.ringLayer?.add(ringAnimation, forKey: dehighlightAnimationKey)
    }
    
    
    private func animateSelection() {
        guard let ringLayer = self.ringLayer else { return }
        guard let innerLayer = self.innerLayer else { return }
        
        ringLayer.removeAllAnimations()
        innerLayer.removeAllAnimations()
        
        let bounceTimingFunction: CAMediaTimingFunction = CAMediaTimingFunction(controlPoints: 0.4, 2.0, 0.3, 1.0)
        let innerFrameSmall = self.bounds.insetBy(dx: ringWidth*2, dy: ringWidth*2)
        
        if state == .on {
            // Animate ring circle
            let borderWidthAnimation = CABasicAnimation(keyPath: "borderWidth")
            let borderWidthFromValue = ringLayer.borderWidth
            ringLayer.borderWidth = ringWidth
            borderWidthAnimation.fromValue = borderWidthFromValue
            borderWidthAnimation.timingFunction = bounceTimingFunction
            
            let ringAnimation = CAAnimationGroup()
            ringAnimation.animations = [borderWidthAnimation]
            ringAnimation.duration = ringAnimationDuration
            ringLayer.add(ringAnimation, forKey: selectAnimationKey)


            // Animate inner circle
            let innerBoundsAnimation = CABasicAnimation(keyPath: "bounds")
            let innerBoundsFromValue = innerLayer.bounds
            innerLayer.bounds = innerFrameSmall
            innerBoundsAnimation.fromValue = innerBoundsFromValue
            innerBoundsAnimation.timingFunction = bounceTimingFunction

            let innerCornerRadiusAnimation = CABasicAnimation(keyPath: "cornerRadius")
            let innerCornerRadiusFromValue = innerLayer.cornerRadius
            innerLayer.cornerRadius = innerFrameSmall.width / 2
            innerCornerRadiusAnimation.fromValue = innerCornerRadiusFromValue
            innerCornerRadiusAnimation.timingFunction = bounceTimingFunction

            let innerAnimation = CAAnimationGroup()
            innerAnimation.animations = [innerBoundsAnimation, innerCornerRadiusAnimation]
            innerAnimation.duration = ringAnimationDuration
            innerLayer.add(innerAnimation, forKey: selectAnimationKey)
        } else {
            // Animate ring circle
            let borderWidthAnimation = CABasicAnimation(keyPath: "borderWidth")
            let borderWidthFromValue = ringLayer.borderWidth
            ringLayer.borderWidth = 0.0
            borderWidthAnimation.fromValue = borderWidthFromValue
            borderWidthAnimation.timingFunction = bounceTimingFunction

            let ringAnimation = CAAnimationGroup()
            ringAnimation.animations = [borderWidthAnimation]
            ringAnimation.duration = ringAnimationDuration
            ringLayer.add(ringAnimation, forKey: deselectAnimationKey)
            
            // Animate inner circle
            let innerBoundsAnimation = CABasicAnimation(keyPath: "bounds")
            let innerBoundsFromValue = innerFrameSmall
            innerLayer.bounds = self.bounds
            innerBoundsAnimation.fromValue = innerBoundsFromValue
            innerBoundsAnimation.timingFunction = bounceTimingFunction

            let innerCornerRadiusAnimation = CABasicAnimation(keyPath: "cornerRadius")
            let innerCornerRadiusFromValue = innerLayer.cornerRadius
            innerLayer.cornerRadius = self.bounds.width / 2
            innerCornerRadiusAnimation.fromValue = innerCornerRadiusFromValue
            innerCornerRadiusAnimation.timingFunction = bounceTimingFunction

            let innerAnimation = CAAnimationGroup()
            innerAnimation.animations = [innerBoundsAnimation, innerCornerRadiusAnimation]
            innerAnimation.duration = ringAnimationDuration
            innerLayer.add(innerAnimation, forKey: deselectAnimationKey)
        }
    }
    
    
    var trackingArea: NSTrackingArea?
    
    func addTrackingArea() {
        // Remove old tracking area
        if trackingArea != nil {
            self.removeTrackingArea(trackingArea!)
            trackingArea = nil
        }
        
        trackingArea = NSTrackingArea(rect: self.bounds, options: [.mouseEnteredAndExited, .activeInKeyWindow], owner: self, userInfo: nil)
        
        // Add tracking area
        self.addTrackingArea(trackingArea!)
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        addTrackingArea()
    }
}
