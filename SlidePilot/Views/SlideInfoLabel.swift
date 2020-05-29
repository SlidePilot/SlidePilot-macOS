//
//  SlideInfoLabel.swift
//  SlidePilot
//
//  Created by Pascal Braband on 28.05.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class SlideInfoLabel: NSTextField {

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    
    
    // MARK: - UI Setup/Update
    
    func setup() {
        self.font = NSFont.systemFont(ofSize: 20.0, weight: .regular)
        self.alignment = .center
        self.isEditable = false
        self.isSelectable = false
        self.isBordered = false
        self.drawsBackground = false
        self.textColor = .white
    }
    
}
