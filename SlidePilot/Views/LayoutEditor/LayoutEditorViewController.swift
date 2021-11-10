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
    
    override func viewDidLoad() {
        arrangementButtonGroup = [arrangementSingleButton, arrangementDoubleButton, arrangementTripleLeftButton, arrangementTripleRightButton]
        
        // Set correct arrangement type for layoutConfigurationView
        layoutConfigurationView.type = DisplayController.layoutConfiguration.type.arrangement
        
        // Select correct arrangement type button, based on current layout configuration
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
        
        // Setup SlideSymbolView's
        currentSlideSymbolView.isDraggable = true
        nextSlideSymbolView.isDraggable = true
        notesSlideSymbolView.isDraggable = true
        
        currentSlideSymbolView.type = .current
        nextSlideSymbolView.type = .next
        notesSlideSymbolView.type = .notes
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
}
