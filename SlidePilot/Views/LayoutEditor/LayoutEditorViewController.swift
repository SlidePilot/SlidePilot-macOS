//
//  LayoutEditorViewController.swift
//  SlidePilot
//
//  Created by Pascal Braband on 09.11.21.
//  Copyright © 2021 Pascal Braband. All rights reserved.
//

import Cocoa

class LayoutEditorViewController: NSViewController {

    @IBOutlet weak var slideSymbol: SlideSymbolView!
    
    override func viewDidLoad() {
        slideSymbol.type = .notes
        slideSymbol.isDraggable = true
    }
    
    @IBAction func symbolCurrent(_ sender: Any) {
        slideSymbol.type = .current
    }
    
    @IBAction func symbolNext(_ sender: Any) {
        slideSymbol.type = .next
    }
    
    @IBAction func symbolNotes(_ sender: Any) {
        slideSymbol.type = .notes
    }
}
