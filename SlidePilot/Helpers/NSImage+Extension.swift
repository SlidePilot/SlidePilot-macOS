//
//  NSImage+Extension.swift
//  SlidePilot
//
//  Created by Pascal Braband on 08.10.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

extension NSImage {
    
    func compressed() -> Data? {
        let factor: CGFloat = 3
        let doubleImageSize = NSSize(width: self.size.width*factor, height: self.size.height*factor)
        let doubleImage = self.resize(size: doubleImageSize)

        guard let cgImg = doubleImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        let imgRep = NSBitmapImageRep(cgImage: cgImg)
        imgRep.size = doubleImageSize
        guard let data = imgRep.representation(using: .jpeg, properties: [.compressionFactor: 1.0]) else { return nil }
        
        return data
    }
    
    
    func resize(size: CGSize) -> NSImage {
        let newImage = NSImage(size: size)
        newImage.lockFocus()
        self.draw(in: NSRect(x: 0, y: 0, width: size.width, height: size.height), from: NSRect(x: 0, y: 0, width: self.size.width, height: self.size.height), operation: .sourceOver, fraction: 1)
        newImage.unlockFocus()
        newImage.size = size
        return newImage
    }
}
