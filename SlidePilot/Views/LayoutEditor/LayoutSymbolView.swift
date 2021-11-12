//
//  LayoutConfigurationView.swift
//  SlidePilot
//
//  Created by Pascal Braband on 10.11.21.
//  Copyright © 2021 Pascal Braband. All rights reserved.
//

import Cocoa

class LayoutConfigurationView: NSView {
    
    var type: LayoutType.Arrangement? = nil {
        didSet {
            self.needsDisplay = true
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
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        
    }

}
