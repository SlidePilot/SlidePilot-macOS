//
//  DrawingToolbar.swift
//  SlidePilot
//
//  Created by Pascal Braband on 10.06.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class DrawingToolbar: NSView {

    /** Indicates if the notice is currently displayed */
    var isShown: Bool {
        return self.superview != nil
    }
    
    // Animation key names
    let showAnimationKey = "show-animation"
    let hideAnimationKey = "hide-animation"
    
    // Colors
    let lineBlueColor = NSColor(red: 0.07, green: 0.55, blue: 0.82, alpha: 1.0)
    let lineGreenColor = NSColor(red: 0.18, green: 0.76, blue: 0.12, alpha: 1.0)
    let lineMagentaColor = NSColor(red: 0.72, green: 0.18, blue: 0.45, alpha: 1.0)
    let lineYellowColor = NSColor(red: 1.0, green: 0.67, blue: 0.0, alpha: 1.0)
    
    // UI Elements
    
    // Swatches
    var blackSwatch: ColorSwatchButton!
    var whiteSwatch: ColorSwatchButton!
    var blueSwatch: ColorSwatchButton!
    var greenSwatch: ColorSwatchButton!
    var magentaSwatch: ColorSwatchButton!
    var yellowSwatch: ColorSwatchButton!
    var swatches: [ColorSwatchButton]!
    
    // Buttons
    var clearButton: IconButton!
    var canvasButton: IconButton!
    var closeButton: IconButton!
    
    let verticalPadding: CGFloat = 20.0
    let horizontalPadding: CGFloat = 40.0
    let buttonPadding: CGFloat = 30.0
    
    let swatchSize: CGFloat = 20.0
    let swatchRingWidth: CGFloat = 2.0
    
    
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    
    func setup() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor(red: 55.0/255.0, green: 55.0/255.0, blue: 55.0/255.0, alpha: 1.0).cgColor
        self.layer?.cornerRadius = 20.0
        
        // Add shadow
        self.shadow = NSShadow()
        self.layer?.shadowOpacity = 1.0
        self.layer?.shadowColor = .black
        self.layer?.shadowOffset = NSMakeSize(0, 0)
        self.layer?.shadowRadius = 20
        
        // Create swatches
        blackSwatch = ColorSwatchButton(color: .black, size: swatchSize, ringWidth: swatchRingWidth)
        whiteSwatch = ColorSwatchButton(color: .white, size: swatchSize, ringWidth: swatchRingWidth)
        blueSwatch = ColorSwatchButton(color: lineBlueColor, size: swatchSize, ringWidth: swatchRingWidth)
        greenSwatch = ColorSwatchButton(color: lineGreenColor, size: swatchSize, ringWidth: swatchRingWidth)
        magentaSwatch = ColorSwatchButton(color: lineMagentaColor, size: swatchSize, ringWidth: swatchRingWidth)
        yellowSwatch = ColorSwatchButton(color: lineYellowColor, size: swatchSize, ringWidth: swatchRingWidth)
        
        swatches = [blackSwatch, whiteSwatch, blueSwatch, greenSwatch, magentaSwatch, yellowSwatch]
        
        blackSwatch.target = self
        blackSwatch.action = #selector(swatchPressed)
        whiteSwatch.target = self
        whiteSwatch.action = #selector(swatchPressed)
        blueSwatch.target = self
        blueSwatch.action = #selector(swatchPressed)
        greenSwatch.target = self
        greenSwatch.action = #selector(swatchPressed)
        magentaSwatch.target = self
        magentaSwatch.action = #selector(swatchPressed)
        yellowSwatch.target = self
        yellowSwatch.action = #selector(swatchPressed)
        
        // Create buttons
        clearButton = createButton(with: NSImage(named: "Eraser")!, action: #selector(clearPressed(_:)))
        canvasButton = createButton(with: NSImage(named: "Canvas")!, action: #selector(canvasPressed(_:)))
        canvasButton.isToggle = true
        closeButton = createButton(with: NSImage(named: "Close")!, action: #selector(closePressed(_:)))
        
        // Add buttons to container
        let container = NSStackView(views: [blackSwatch, whiteSwatch, blueSwatch, greenSwatch, magentaSwatch, yellowSwatch, clearButton, canvasButton, closeButton])
        container.translatesAutoresizingMaskIntoConstraints = false
        container.orientation = .horizontal
        container.spacing = buttonPadding
        container.setCustomSpacing(buttonPadding + 20.0, after: canvasButton)
        self.addSubview(container)
        self.addConstraints([
            NSLayoutConstraint(item: container, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: horizontalPadding),
            NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: container, attribute: .right, multiplier: 1.0, constant: horizontalPadding),
            NSLayoutConstraint(item: container, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: verticalPadding),
            NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: verticalPadding + (layer?.cornerRadius ?? 20.0) + 10.0)])
        
        CanvasController.subscribeCanvasBackgroundChanged(target: self, action: #selector(canvasBackgroundDidChange(_:)))
    }
    
    
    private func createButton(with image: NSImage, action: Selector) -> IconButton {
        
        let imageButton = IconButton()
        imageButton.image = image
        imageButton.backgroundColor = NSColor(white: 0.35, alpha: 1.0)
        imageButton.target = self
        imageButton.action = action
        imageButton.addConstraints([
            NSLayoutConstraint(item: imageButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 35.0),
            NSLayoutConstraint(item: imageButton, attribute: .height, relatedBy: .equal, toItem: imageButton, attribute: .width, multiplier: 1.0, constant: 0.0)])
        return imageButton
    }
    
    
    private func deselectAllSwatches() {
        swatches.forEach({ $0.state = .off })
    }
    
    
    @objc func swatchPressed(_ sender: ColorSwatchButton) {
        swatches
            .filter({ $0 != sender })
            .forEach({ $0.state = .off })
        sender.state = .on
        
        // Set current drawing color to swatch color
        CanvasController.setDrawingColor(to: sender.color, sender: self)
    }
    
    
    @objc func clearPressed(_ sender: IconButton) {
        CanvasController.clearCanvas(sender: self)
    }
    
    
    @objc func canvasPressed(_ sender: IconButton) {
        CanvasController.setTransparentCanvasBackground(sender.state == .off, sender: sender)
    }
    
    
    @objc func closePressed(_ sender: IconButton) {
        DisplayController.setDisplayDrawingTools(false, sender: self)
    }
    
    
    
    
    // MARK: - Show/Hide Methdos
    
    var bottomConstraint: NSLayoutConstraint?
    
    /**
     Shows the drawing toolbar.
     */
    func show(in parentView: NSView) {
        // Select swatch for current drawing color
        if let swatchForCurrentDrawingColor = swatches.first(where: { $0.color == CanvasController.drawingColor }) {
            swatchPressed(swatchForCurrentDrawingColor)
        }
        
        // If hide animation is currently running:
        // Remove hide animation and remove from superview
        if isHideAnimationRunning() {
            self.layer?.removeAnimation(forKey: hideAnimationKey)
            self.removeFromSuperview()
        }
        
        // Only continue presenting, if not already shown
        guard !isShown else { return }
        
        // In superview drop from top with bounce animation
        parentView.addSubview(self)
        self.layoutSubtreeIfNeeded()
        bottomConstraint = NSLayoutConstraint(item: parentView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -(layer?.cornerRadius ?? 20.0) - 10.0)
        let centerConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: parentView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        parentView.addConstraints([bottomConstraint!, centerConstraint])
        
        // Layout view before animating
        parentView.updateConstraints()
        parentView.layoutSubtreeIfNeeded()
        
        // Create bouncing animation
        let animation = CABasicAnimation(keyPath: "position.y")
        animation.duration = 0.4
        animation.isAdditive = true
        animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 1.5, 0.3, 1.0)
        animation.fromValue = -(self.frame.height + bottomConstraint!.constant + 10.0)
        animation.toValue = 0.0
        
        self.layer?.add(animation, forKey: showAnimationKey)
    }
    
    
    /** Hides the notice. */
    func hide() {
        self.layer?.removeAnimation(forKey: showAnimationKey)
        
        // Save previous value of top constraint for animation start value
        let bottomConstraintConstantBeforeAnimation = bottomConstraint?.constant ?? 0
        
        // Reset top constraint to make view hidden
        self.bottomConstraint?.constant = -(self.frame.height + 10.0)
        self.superview?.updateConstraints()
        self.superview?.layoutSubtreeIfNeeded()
        
        CATransaction.begin()
        // Remove view on animation completion
        CATransaction.setCompletionBlock {
            // Only remove if show animation is not running
            if !self.isShowAnimationRunning() {
                self.removeFromSuperview()
            }
        }
        
        // Create bouncing out animation
        let animation = CABasicAnimation(keyPath: "position.y")
        animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.7, -0.65, 0.95, 0.75)
        animation.duration = 0.3
        animation.isAdditive = true
        animation.fromValue = abs(bottomConstraint?.constant ?? 0) + bottomConstraintConstantBeforeAnimation
        animation.toValue = 0.0
        self.layer?.add(animation, forKey: hideAnimationKey)
        
        CATransaction.commit()
    }
    
    
    func isShowAnimationRunning() -> Bool {
        return self.layer?.animation(forKey: showAnimationKey) != nil
    }
    
    
    func isHideAnimationRunning() -> Bool {
        return self.layer?.animation(forKey: hideAnimationKey) != nil
    }
    
    
    
    
    // MARK: - Control Handlers
    
    @objc func canvasBackgroundDidChange(_ notification: Notification) {
        canvasButton.state = CanvasController.isCanvasBackgroundTransparent ? .off : .on
    }
}
