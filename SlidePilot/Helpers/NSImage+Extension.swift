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
        guard let cgImg = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        let imgRep = NSBitmapImageRep(cgImage: cgImg)
        imgRep.size = self.size
        guard let data = imgRep.representation(using: .jpeg, properties: [.compressionFactor: 1.0]) else { return nil }
        print(data.count)
        return data
    }
}
