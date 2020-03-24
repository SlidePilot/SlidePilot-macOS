//
//  PresentationWindowController.swift
//  Slidejar
//
//  Created by Pascal Braband on 24.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class PresentationWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()

        self.window?.title = NSLocalizedString("Presentation", comment: "Window name for the presentation view.")
    }
    
}
