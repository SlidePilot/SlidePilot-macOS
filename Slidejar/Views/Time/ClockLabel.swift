//
//  ClockLabel.swift
//  Slidejar
//
//  Created by Pascal Braband on 23.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class ClockLabel: NSTextField {

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    
    private func setup() {        
        // Inital time
        updateLabel()
        
        // Start clock
        let clockTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateLabel), userInfo: nil, repeats: true)
        RunLoop.main.add(clockTimer, forMode: RunLoop.Mode.common)
    }
    
    
    @objc private func updateLabel() {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        self.stringValue = timeFormatter.string(from: Date())
    }
}
