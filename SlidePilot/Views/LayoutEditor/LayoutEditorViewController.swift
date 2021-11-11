//
//  LayoutEditorViewController.swift
//  SlidePilot
//
//  Created by Pascal Braband on 09.11.21.
//  Copyright © 2021 Pascal Braband. All rights reserved.
//

import Cocoa

class LayoutEditorViewController: NSViewController {
    
    @IBOutlet weak var arrangementSingleButton: NSButton!
    @IBOutlet weak var arrangementDoubleButton: NSButton!
    @IBOutlet weak var arrangementTripleLeftButton: NSButton!
    @IBOutlet weak var arrangementTripleRightButton: NSButton!
    var arrangementButtonGroup: [NSButton]!
    
    @IBOutlet weak var layoutConfigurationView: LayoutConfigurationView!
    
    @IBOutlet weak var currentSlideSymbolView: SlideSymbolView!
    @IBOutlet weak var nextSlideSymbolView: SlideSymbolView!
    @IBOutlet weak var notesSlideSymbolView: SlideSymbolView!
    
    @IBOutlet weak var layoutPaddingNoneButton: NSButton!
    @IBOutlet weak var layoutPaddingSmallButton: NSButton!
    @IBOutlet weak var layoutPaddingNormalButton: NSButton!
    
    @IBOutlet weak var timeSizeHiddenButton: NSButton!
    @IBOutlet weak var timeSizeSmallButton: NSButton!
    @IBOutlet weak var timeSizeNormalButton: NSButton!
    
    
    override func viewDidLoad() {
        arrangementButtonGroup = [arrangementSingleButton, arrangementDoubleButton, arrangementTripleLeftButton, arrangementTripleRightButton]
        
        // Set correct arrangement type for layoutConfigurationView
        layoutConfigurationView.type = DisplayController.layoutConfiguration.type.arrangement
        
        // Subscribe to updates of layout configuration
        DisplayController.subscribeLayoutConfiguration(target: self, action: #selector(layoutConfigurationDidChange(_:)))
        
        // Select correct arrangement type button, based on current layout configuration
        updateArrangementSelectButtonState()
        
        // Select correct layout padding button
        updateLayoutPaddingButtonState()
        
        // Select correct time size button
        updateTimeSizeButtonState()
        
        // Setup SlideSymbolView's
        currentSlideSymbolView.isDraggable = true
        nextSlideSymbolView.isDraggable = true
        notesSlideSymbolView.isDraggable = true
        
        currentSlideSymbolView.type = .current
        nextSlideSymbolView.type = .next
        notesSlideSymbolView.type = .notes
    }
    
    
    func updateArrangementSelectButtonState() {
        arrangementButtonGroup.forEach({ $0.state = .off })
        switch DisplayController.layoutConfiguration.type.arrangement {
        case .single:
            arrangementSingleButton.state = .on
        case .double:
            arrangementDoubleButton.state = .on
        case .tripleLeft:
            arrangementTripleLeftButton.state = .on
        case .tripleRight:
            arrangementTripleRightButton.state = .on
        }
    }
    
    
    func updateLayoutPaddingButtonState() {
        switch PreferencesController.layoutPadding {
        case .none:
            layoutPaddingNoneButton.state = .on
        case .small:
            layoutPaddingSmallButton.state = .on
        case .normal:
            layoutPaddingNormalButton.state = .on
        }
    }
    
    
    func updateTimeSizeButtonState() {
        switch PreferencesController.timeSize {
        case .hidden:
            timeSizeHiddenButton.state = .on
        case .small:
            timeSizeSmallButton.state = .on
        case .normal:
            timeSizeNormalButton.state = .on
        }
    }
    
    
    @objc func layoutConfigurationDidChange(_ notification: Notification) {
        updateArrangementSelectButtonState()
    }
    
    
    @IBAction func arrangementSelected(_ sender: NSButton) {
        // Turn off the other buttons
        for button in arrangementButtonGroup {
            if button != sender {
                button.state = .off
            }
        }
        
        // Setup layout configurator
        switch sender {
        case arrangementSingleButton:
            DisplayController.setLayoutConfigurationType(.single, sender: self)
        case arrangementDoubleButton:
            DisplayController.setLayoutConfigurationType(.double, sender: self)
        case arrangementTripleLeftButton:
            DisplayController.setLayoutConfigurationType(.tripleLeft, sender: self)
        case arrangementTripleRightButton:
            DisplayController.setLayoutConfigurationType(.tripleRight, sender: self)
        default:
            break
        }
    }
    
    @IBAction func selectLayoutPadding(_ sender: NSButton) {
        switch sender {
        case layoutPaddingNoneButton:
            PreferencesController.setLayoutPadding(.none, sender: sender)
        case layoutPaddingSmallButton:
            PreferencesController.setLayoutPadding(.small, sender: sender)
        case layoutPaddingNormalButton:
            PreferencesController.setLayoutPadding(.normal, sender: sender)
        default:
            break
        }
    }
    
    @IBAction func selectTimeSize(_ sender: NSButton) {
        switch sender {
        case timeSizeHiddenButton:
            PreferencesController.setTimeSize(.hidden, sender: sender)
        case timeSizeSmallButton:
            PreferencesController.setTimeSize(.small, sender: sender)
        case timeSizeNormalButton:
            PreferencesController.setTimeSize(.normal, sender: sender)
        default:
            break
        }
    }
}
