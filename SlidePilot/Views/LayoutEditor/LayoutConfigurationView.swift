//
//  LayoutConfigurationView.swift
//  SlidePilot
//
//  Created by Pascal Braband on 10.11.21.
//  Copyright © 2021 Pascal Braband. All rights reserved.
//

import Cocoa

class LayoutConfigurationView: NSView {
    
    var layoutSlidePos1: LayoutSlideView!
    var layoutSlidePos2: LayoutSlideView!
    var layoutSlidePos3: LayoutSlideView!
    var separatorView: NSView!

    
    var type: LayoutType.Arrangement? = nil {
        didSet {
            self.updateViews()
        }
    }
    
    init(type: LayoutType.Arrangement?) {
        super.init(frame: .zero)
        self.type = type
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        self.wantsLayer = true
        
        // Setup SlideSymbolView's
        layoutSlidePos1 = LayoutSlideView(frame: .zero)
        layoutSlidePos1.translatesAutoresizingMaskIntoConstraints = false
        layoutSlidePos1.delegate = self
        self.addSubview(layoutSlidePos1)
        
        layoutSlidePos2 = LayoutSlideView(frame: .zero)
        layoutSlidePos2.translatesAutoresizingMaskIntoConstraints = false
        layoutSlidePos2.delegate = self
        self.addSubview(layoutSlidePos2)
        
        layoutSlidePos3 = LayoutSlideView(frame: .zero)
        layoutSlidePos3.translatesAutoresizingMaskIntoConstraints = false
        layoutSlidePos3.delegate = self
        self.addSubview(layoutSlidePos3)
        
        separatorView = NSView(frame: .zero)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.wantsLayer = true
        separatorView.layer?.backgroundColor = NSColor(white: 0.75, alpha: 1.0).cgColor
        
        // Subscribe to events on layout configuration changes
        DisplayController.subscribeLayoutConfiguration(target: self, action: #selector(layoutConfigurationDidChange(_:)))
        
        updateViews()
    }
    
    func updateViews() {
        // Remove all subviews
        self.subviews.forEach({ $0.removeFromSuperview() })
        
        // Setup view based on arrangement type
        switch DisplayController.layoutConfiguration.type {
        case .single:
            setupSingleArrangement()
            
        case .double:
            setupDoubleArrangement()
            
        case .tripleLeft:
            setupTripleLeftArrangement()
            
        case .tripleRight:
            setupTripleRightArrangement()
            
        default:
            break
        }
        
        // Setup slide symbol of each LayoutSlideView
        layoutSlidePos1.slideSymbol.type = DisplayController.layoutConfiguration.slides[0]
        layoutSlidePos2.slideSymbol.type = DisplayController.layoutConfiguration.slides[1]
        layoutSlidePos3.slideSymbol.type = DisplayController.layoutConfiguration.slides[2]
    }
    
    func setupSingleArrangement() {
        self.addSubview(layoutSlidePos1)
        
        self.addConstraints([
            NSLayoutConstraint(item: layoutSlidePos1!, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.7, constant: 0.0),
            NSLayoutConstraint(item: layoutSlidePos1!, attribute: .height, relatedBy: .equal, toItem: layoutSlidePos1!, attribute: .width, multiplier: 0.75, constant: 0.0),
            NSLayoutConstraint(item: layoutSlidePos1!, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: layoutSlidePos1!, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0),
        ])
    }
    
    func setupDoubleArrangement() {
        self.addSubview(separatorView)
        self.addSubview(layoutSlidePos1)
        self.addSubview(layoutSlidePos2)
        
        self.addConstraints([
            NSLayoutConstraint(item: layoutSlidePos1!, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.4, constant: 0.0),
            NSLayoutConstraint(item: layoutSlidePos1!, attribute: .height, relatedBy: .equal, toItem: layoutSlidePos1!, attribute: .width, multiplier: 0.75, constant: 0.0),
            NSLayoutConstraint(item: layoutSlidePos1!, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: layoutSlidePos1!, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0),
            
            NSLayoutConstraint(item: layoutSlidePos2!, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.4, constant: 0.0),
            NSLayoutConstraint(item: layoutSlidePos2!, attribute: .height, relatedBy: .equal, toItem: layoutSlidePos2!, attribute: .width, multiplier: 0.75, constant: 0.0),
            NSLayoutConstraint(item: layoutSlidePos2!, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: layoutSlidePos2!, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0),
            
            NSLayoutConstraint(item: separatorView!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 2.5),
            NSLayoutConstraint(item: separatorView!, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0.95, constant: 0.0),
            NSLayoutConstraint(item: separatorView!, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: separatorView!, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0),
        ])
    }
    
    func setupTripleLeftArrangement() {
        self.addSubview(separatorView)
        self.addSubview(layoutSlidePos3)
        
        let containerView = setupContainerDoubleSlide()
        
        self.addConstraints([
            NSLayoutConstraint(item: layoutSlidePos3!, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.4, constant: 0.0),
            NSLayoutConstraint(item: layoutSlidePos3!, attribute: .height, relatedBy: .equal, toItem: layoutSlidePos3!, attribute: .width, multiplier: 0.75, constant: 0.0),
            NSLayoutConstraint(item: layoutSlidePos3!, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: layoutSlidePos3!, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0),
            
            NSLayoutConstraint(item: containerView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.4, constant: 0.0),
            NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: containerView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0),
            
            NSLayoutConstraint(item: separatorView!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 2.5),
            NSLayoutConstraint(item: separatorView!, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0.95, constant: 0.0),
            NSLayoutConstraint(item: separatorView!, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: separatorView!, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0),
        ])
    }
    
    func setupTripleRightArrangement() {
        self.addSubview(separatorView)
        self.addSubview(layoutSlidePos3)
        
        let containerView = setupContainerDoubleSlide()
        
        self.addConstraints([
            NSLayoutConstraint(item: layoutSlidePos3!, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.4, constant: 0.0),
            NSLayoutConstraint(item: layoutSlidePos3!, attribute: .height, relatedBy: .equal, toItem: layoutSlidePos3!, attribute: .width, multiplier: 0.75, constant: 0.0),
            NSLayoutConstraint(item: layoutSlidePos3!, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: layoutSlidePos3!, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0),
            
            NSLayoutConstraint(item: containerView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.4, constant: 0.0),
            NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: containerView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0),
            
            NSLayoutConstraint(item: separatorView!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 2.5),
            NSLayoutConstraint(item: separatorView!, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0.95, constant: 0.0),
            NSLayoutConstraint(item: separatorView!, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: separatorView!, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0),
        ])
        
        
    }
    
    func setupContainerDoubleSlide() -> NSView {
        let containerView = NSView(frame: .zero)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(containerView)
        containerView.addSubview(layoutSlidePos1)
        containerView.addSubview(layoutSlidePos2)
        
        containerView.addConstraints([
            NSLayoutConstraint(item: layoutSlidePos1!, attribute: .width, relatedBy: .equal, toItem: containerView, attribute: .width, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: layoutSlidePos1!, attribute: .height, relatedBy: .equal, toItem: layoutSlidePos1!, attribute: .width, multiplier: 0.75, constant: 0.0),
            NSLayoutConstraint(item: layoutSlidePos1!, attribute: .left, relatedBy: .equal, toItem: containerView, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: layoutSlidePos1!, attribute: .right, relatedBy: .equal, toItem: containerView, attribute: .right, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: layoutSlidePos1!, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1.0, constant: 0.0),
            
            NSLayoutConstraint(item: layoutSlidePos2!, attribute: .width, relatedBy: .equal, toItem: containerView, attribute: .width, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: layoutSlidePos2!, attribute: .height, relatedBy: .equal, toItem: layoutSlidePos2!, attribute: .width, multiplier: 0.75, constant: 0.0),
            NSLayoutConstraint(item: layoutSlidePos2!, attribute: .left, relatedBy: .equal, toItem: containerView, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: layoutSlidePos2!, attribute: .right, relatedBy: .equal, toItem: containerView, attribute: .right, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: layoutSlidePos2!, attribute: .bottom, relatedBy: .equal, toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            
            NSLayoutConstraint(item: layoutSlidePos1!, attribute: .bottom, relatedBy: .equal, toItem: layoutSlidePos2!, attribute: .top, multiplier: 1.0, constant: -20.0),
        ])
        
        return containerView
    }
    
    @objc func layoutConfigurationDidChange(_ notifcation: Notification) {
        updateViews()
    }
}




extension LayoutConfigurationView: LayoutSlideViewDelegate {
    
    func slideTypeDidChange(to slideType: SlideType, sender: LayoutSlideView) {
        // Updated layout configuration when slide type for a LayoutSlideView changed
        var newLayoutConfiguration = DisplayController.layoutConfiguration
        
        switch sender {
        case layoutSlidePos1:
            newLayoutConfiguration.moveSlide(slideType, to: 0)
        case layoutSlidePos2:
            newLayoutConfiguration.moveSlide(slideType, to: 1)
        case layoutSlidePos3:
            newLayoutConfiguration.moveSlide(slideType, to: 2)
        default:
            break
        }
        
        DisplayController.setLayoutConfiguration(newLayoutConfiguration, sender: sender)
    }
}
