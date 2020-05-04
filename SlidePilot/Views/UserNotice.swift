//
//  UserNotice.swift
//  SlidePilot
//
//  Created by Pascal Braband on 04.05.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class UserNotice: NSView {
    
    /**
     Defines the icon image being displayed with the notice.
     Maps case to `NSImage` name.
     */
    enum Style: String {
        case warning = "WarningTriangle"
    }
    
    /** Indicates if the notice is currently displayed */
    var isShown: Bool {
        return self.superview != nil
    }
    
    /** Stores the notice style*/
    var style: Style = .warning {
        didSet {
            imageView?.image = NSImage(named: style.rawValue)
        }
    }
    
    /** Stores the notice message */
    var message: String = "" {
        didSet {
            messageLabel?.stringValue = message
        }
    }
    
    /** Defines the maximum width of the notice */
    var maxWidth: CGFloat = 200.0 {
        didSet {
            widthConstraint?.constant = self.maxWidth
        }
    }
    
    // UI Elements
    var messageLabel: NSTextField?
    var imageView: NSImageView?
    
    
    // Constraints
    
    /** The top constraint for the notice, which will be animated. */
    var topConstraint: NSLayoutConstraint?
    
    /** The width constraint of the notice */
    var widthConstraint: NSLayoutConstraint?

    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        setup(style: .warning, message: "")
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup(style: .warning, message: "")
    }
    
    
    /**
     - parameters:
        - style: The Style of the notice.
        - message: The message, that should be displayed in the notice.
        - duratino: The duration, for how long the notice should be displayed
     */
    init(style: Style, message: String) {
        super.init(frame: .zero)
        setup(style: style, message: message)
    }
    
    
    func setup(style: Style, message: String) {
        self.style = style
        self.message = message
        
        // Setup view
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor(red: 100.0/255.0, green: 100.0/255.0, blue: 100.0/255.0, alpha: 1.0).cgColor
        self.layer?.cornerRadius = 10.0
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup Label
        messageLabel = NSTextField()
        messageLabel!.translatesAutoresizingMaskIntoConstraints = false
        messageLabel!.font = NSFont.systemFont(ofSize: 15.0, weight: .regular)
        messageLabel!.alignment = .center
        messageLabel!.isEditable = false
        messageLabel!.isSelectable = false
        messageLabel!.isBordered = false
        messageLabel!.drawsBackground = false
        messageLabel!.textColor = .white
        messageLabel!.stringValue = message
        
        // Setup Image View
        imageView = NSImageView()
        imageView!.translatesAutoresizingMaskIntoConstraints = false
        imageView!.imageScaling = .scaleProportionallyUpOrDown
        imageView!.image = NSImage(named: style.rawValue)
        
        imageView!.addConstraints([
            NSLayoutConstraint(item: imageView!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 20.0),
            NSLayoutConstraint(item: imageView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 20.0)])
        
        self.addSubview(messageLabel!)
        self.addSubview(imageView!)
        
        // Add constraints
        widthConstraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: maxWidth)
        self.addConstraints([
            widthConstraint!,
            NSLayoutConstraint(item: imageView!, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: imageView!, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 20.0),
            NSLayoutConstraint(item: imageView!, attribute: .right, relatedBy: .equal, toItem: messageLabel, attribute: .left, multiplier: 1.0, constant: -15.0),
            NSLayoutConstraint(item: messageLabel!, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: -20.0),
            NSLayoutConstraint(item: messageLabel!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 12.0),
            NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: messageLabel, attribute: .bottom, multiplier: 1.0, constant: 12.0)])
    }
    
    
    /**
     Shows the configured notice.
     
     - parameters:
        - duration: If a duration time interval is given, the notice will hide itself automatically after the duration. Otherwise the notice will be displayed permanently, until it is manually hidden with `hide()`.
     */
    func show(in parentView: NSView, duration: TimeInterval? = nil) {
        // In superview drop from top with bounce animation
        parentView.addSubview(self)
        self.layoutSubtreeIfNeeded()
        topConstraint = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: parentView, attribute: .top, multiplier: 1.0, constant: 30.0)
        let centerConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: parentView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        parentView.addConstraints([topConstraint!, centerConstraint])
        
        // Layout view before animating
        parentView.updateConstraints()
        parentView.layoutSubtreeIfNeeded()
        
        // Create bouncing animation
        let animation = CAKeyframeAnimation.animation(
            with: "position.y",
            from: Double(self.frame.height + topConstraint!.constant + 10.0),
            to: 0.0,
            timingFuntion: CAKeyframeAnimation.elasticOutTimingFuction)
        
        animation.duration = 0.6
        animation.isAdditive = true
        self.layer?.add(animation, forKey: "bounce-in")
        
        // Auto-hide when duration is given
        if let duration = duration {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                self.hide()
            }
        }
    }
    
    
    /** Hides the notice. */
    func hide() {
        // Save previous value of top constraint for animation start value
        let topConstraintConstantBeforeAnimation = topConstraint?.constant ?? 0
        
        // Reset top constraint to make view hidden
        self.topConstraint?.constant = -(self.frame.height + 10.0)
        self.superview?.updateConstraints()
        self.superview?.layoutSubtreeIfNeeded()
        
        CATransaction.begin()
        // Remove view on animation completion
        CATransaction.setCompletionBlock {
            self.removeFromSuperview()
        }
        
        // Create bouncing out animation
        let animation = CABasicAnimation(keyPath: "position.y")
        animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.7, -0.65, 0.95, 0.75)
        animation.duration = 0.3
        animation.isAdditive = true
        animation.fromValue = (topConstraint?.constant ?? 0) - topConstraintConstantBeforeAnimation
        animation.toValue = 0.0
        self.layer?.add(animation, forKey: "bounce-out")
        
        CATransaction.commit()
    }
    
}
