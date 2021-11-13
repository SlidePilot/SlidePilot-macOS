//
//  NSView+Extension.swift
//  SlidePilot
//
//  Created by Pascal Braband on 10.11.21.
//  Copyright © 2021 Pascal Braband. All rights reserved.
//

import Cocoa

extension NSView {
    
    /**
     Take a snapshot of the NSView's current state and return an NSImage.
     
     - returns: NSImage representation of the view's state.
     */
    public func image() -> NSImage {
        let imageRepresentation = bitmapImageRepForCachingDisplay(in: bounds)!
        cacheDisplay(in: bounds, to: imageRepresentation)
        return NSImage(cgImage: imageRepresentation.cgImage!, size: bounds.size)
    }
}
