//
//  PresentationViewController.swift
//  SlidePilot
//
//  Created by Pascal Braband on 24.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class PresentationViewController: NSViewController {

    @IBOutlet weak var pageView: PDFPageView!
    var pointer: PointerView?
    var isPointerShown: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.black.cgColor
        
        // Subscribe to page changes
        PageController.subscribeDidSelectPage(target: self, action: #selector(pageDidChange(_:)))
        
        // Subscribe to document changes
        DocumentController.subscribeDidOpenDocument(target: self, action: #selector(documentDidChange(_:)))
        
        // Subscribe to display changes
        DisplayController.subscribeNotesPosition(target: self, action: #selector(notesPositionDidChange(_:)))
        DisplayController.subscribeDisplayBlackCurtain(target: self, action: #selector(displayBlackCurtainDidChange(_:)))
        DisplayController.subscribeDisplayWhiteCurtain(target: self, action: #selector(displayWhiteCurtainDidChange(_:)))
        DisplayController.subscribePointerAppearance(target: self, action: #selector(pointerAppearanceDidChange(_:)))
        DisplayController.subscribePresentationFrozen(target: self, action: #selector(presentationFrozenDidChange(_:)))
    }
    
    
    
    
    // MARK: - Control Handlers
    
    @objc private func pageDidChange(_ notification: Notification) {
        // Only change page if screen is not frozen
        if !DisplayController.isPresentationFrozen {
            pageView.setCurrentPage(PageController.currentPage)
        }
    }
    
    
    @objc func documentDidChange(_ notification: Notification) {
        pageView.setDocument(DocumentController.document)
    }
    
    
    @objc func notesPositionDidChange(_ notification: Notification) {
        pageView.setDisplayMode(DisplayController.notesPosition.displayModeForPresentation())
    }
    
    
    @objc func displayBlackCurtainDidChange(_ notification: Notification) {
        // Un-/Cover screen with black curtain, depending on isWhiteCurtainDisplay
        if DisplayController.isBlackCurtainDisplayed {
            pageView.coverBlack()
        } else {
            pageView.uncover()
        }
    }
    
    
    @objc func displayWhiteCurtainDidChange(_ notification: Notification) {
        // Un-/Cover screen with white curtain, depending on isWhiteCurtainDisplay
        if DisplayController.isWhiteCurtainDisplayed {
            pageView.coverWhite()
        } else {
            pageView.uncover()
        }
    }
    
    
    @objc func presentationFrozenDidChange(_ notification: Notification) {
        // Unfreeze screen, depending on isPresentationFrozen
        if !DisplayController.isPresentationFrozen {
            pageView.setCurrentPage(PageController.currentPage)
        }
    }
    
    
    @objc func pointerAppearanceDidChange(_ notification: Notification) {
        switch DisplayController.pointerAppearance {
        case .cursor:
            pointer?.type = .cursor
        case .dot:
            pointer?.type = .dot
        case .circle:
            pointer?.type = .circle
        case .target:
            pointer?.type = .target
        case .targetColor:
            pointer?.type = .targetColor
        }
    }
}




extension PresentationViewController: MousePointerDelegate {
    
    func showPointer() {
        if pointer == nil {
            pointer = PointerView(origin: NSPoint(x: self.view.frame.midX, y: self.view.frame.midY), type: DisplayController.pointerAppearance)
            self.view.addSubview(pointer!)
        }
        isPointerShown = true
    }
    
    
    func hidePointer() {
        pointer?.removeFromSuperview()
        pointer = nil
        isPointerShown = false
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
