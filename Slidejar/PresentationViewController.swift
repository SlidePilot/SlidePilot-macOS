//
//  PresentationViewController.swift
//  Slidejar
//
//  Created by Pascal Braband on 24.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class PresentationViewController: NSViewController {

    @IBOutlet weak var pageView: PDFPageView!
    var pointer: PointerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.black.cgColor
    }
}




extension PresentationViewController: MousePointerDelegate {
    
    func showPointer() {
        if pointer == nil {
            pointer = PointerView(frame: NSRect(x: 100, y: 100, width: 10.0, height: 10.0), type: .cursor)
            self.view.addSubview(pointer!)
        }
    }
    
    
    func hidePointer() {
        pointer?.removeFromSuperview()
        pointer = nil
    }
    
    
    func pointerMoved(to position: NSPoint) {
        pointer?.setPosition(calculateAbsolutePosition(for: position, in: pageView))
    }
    
    
    func calculateAbsolutePosition(for position: NSPoint, in view: NSImageView) -> NSPoint {
        let imageViewOrigin = view.convert(view.frame.origin, to: self.view)
        let imageFrame = view.imageRect()
        let imageOrigin = imageFrame.origin
        
        // Calculate absolute position in displayed image
        let absoluteInImage = NSPoint(x: imageFrame.width * position.x, y: imageFrame.height * position.y)
        
        // Calculate absolute position in view
        let absoluteInView = NSPoint(x: absoluteInImage.x + imageViewOrigin.x + imageOrigin.x,
                                     y: absoluteInImage.y + imageViewOrigin.y + imageOrigin.y)
        
        return absoluteInView
    }
}
