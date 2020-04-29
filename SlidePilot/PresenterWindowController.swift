//
//  PresenterWindowController.swift
//  SlidePilot
//
//  Created by Pascal Braband on 24.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class PresenterWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.window?.title = NSLocalizedString("Presenter Display", comment: "Window name for the presenter view.")
        self.window?.center()
        
        self.window?.backgroundColor = NSColor(white: 0.07, alpha: 1.0)
    }
    
    
    @available(OSX 10.12.2, *)
    override func makeTouchBar() -> NSTouchBar? {
        guard let viewController = contentViewController as? PresenterViewController else {
            return nil
        }
        return viewController.makeTouchBar()
    }

}
