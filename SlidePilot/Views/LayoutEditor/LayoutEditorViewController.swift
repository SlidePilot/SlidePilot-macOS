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
        layoutConfigurationView.type = .single
        arrangementSingleButton.state = .on
        
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
            layoutConfigurationView.type = .single
        case arrangementDoubleButton:
            layoutConfigurationView.type = .double
        case arrangementTripleLeftButton:
            layoutConfigurationView.type = .tripleLeft
        case arrangementTripleRightButton:
            layoutConfigurationView.type = .tripleRight
        default:
            break
        }
    }
}
