//
//  NSColor+Extension.swift
//  SlidePilot
//
//  Created by Pascal Braband on 23.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

extension NSColor {
    
    func image(of size: NSSize) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()
        self.drawSwatch(in: NSRect(x: 0, y: 0, width: size.width, height: size.height))
        image.unlockFocus()
        return image
    }
}
