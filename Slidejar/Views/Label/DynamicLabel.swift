//
//  DynamicLabel.swift
//  Slidejar
//
//  Created by Pascal Braband on 23.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class DynamicLabel: NSTextField, NSWindowDelegate {
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        NotificationCenter.default.addObserver(self, selector: #selector(receiveWindowResize), name: NSNotification.Name(rawValue: "WindowDidResize"), object: nil)
    }
    
    func windowDidResize(_ notification: Notification) {
        print("\(Date()) resize")
//        guard let currentFont = font else { return }
//        let bestFittingFont = NSFont.bestFittingFont(for: stringValue, in: bounds, fontDescriptor: currentFont.fontDescriptor, additionalAttributes: [:])
//        font = bestFittingFont
        
    }
    
    
    @objc private func receiveWindowResize() {
        print("receive")
        self.fitTextToBounds()
    }
    
}
