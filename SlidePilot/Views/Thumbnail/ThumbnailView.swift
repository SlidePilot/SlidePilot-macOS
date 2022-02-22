//
//  ThumbnailView.swift
//  SlidePilot
//
//  Created by Pascal Braband on 31.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa
import PDFKit


class ThumbnailView: ClipfreeView {
    
    var page: PDFPageView!
    var canvas: CanvasView!
    var label: NSTextField!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    
    private func setup() {
        page = PDFPageView(frame: .zero)
        page.areLinksEnabled = false
        page.translatesAutoresizingMaskIntoConstraints = false
        
        canvas = CanvasView(drawing: Drawing())
        canvas.translatesAutoresizingMaskIntoConstraints = false
        canvas.allowsDrawing = false
        
        label = NSTextField(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label!.font = NSFont.systemFont(ofSize: 10.0, weight: .regular)
        label!.alignment = .center
        label!.isEditable = false
        label!.isSelectable = false
        label!.isBordered = false
        label!.drawsBackground = false
        label!.textColor = .white
        
        label.addConstraint(NSLayoutConstraint(item: label!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 25.0))
        
        page.setContentCompressionResistancePriority(NSLayoutConstraint.Priority(rawValue: 250.0), for: .horizontal)
        page.setContentCompressionResistancePriority(NSLayoutConstraint.Priority(rawValue: 250.0), for: .vertical)
        
        self.addSubview(page)
        self.addSubview(canvas)
        self.addSubview(label)
        self.addConstraints([
            NSLayoutConstraint(item: label!, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: label!, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: label!, attribute: .right, relatedBy: .equal, toItem: page, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: page!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: page!, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: page!, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            
            NSLayoutConstraint(item: canvas!, attribute: .left, relatedBy: .equal, toItem: page!, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: canvas!, attribute: .right, relatedBy: .equal, toItem: page!, attribute: .right, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: canvas!, attribute: .top, relatedBy: .equal, toItem: page!, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: canvas!, attribute: .bottom, relatedBy: .equal, toItem: page!, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        ])
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateBorder), name: NSView.frameDidChangeNotification, object: self)
    }
    
    
    
    
    // MARK: - Border
    
    var borderView: NSView?
    
    let borderColor = NSColor(white: 0.6, alpha: 1.0)
    var borderWidth: CGFloat = 1.0
    
    @objc public func updateBorder() {
        if borderView != nil {
            borderView!.removeFromSuperview()
            borderView = nil
        }
        
        self.layoutSubtreeIfNeeded()
        let imageFrame = page.imageRect()
        let pageFrame = NSRect(x: page.frame.minX + imageFrame.minX, y: page.frame.minY + imageFrame.minY, width: imageFrame.width, height: imageFrame.height-1)
        borderView = NSView(frame: pageFrame.insetBy(dx: -borderWidth, dy: min(0, -borderWidth)))
        borderView?.wantsLayer = true
        borderView?.layer?.borderWidth = borderWidth
        borderView?.layer?.borderColor = borderColor.cgColor
        borderView?.layer?.cornerRadius = 3.0
        
        self.addSubview(borderView!)
    }
    
    
    let selectionPrimaryBorderColor = NSColor(red: 238.0/255.0, green: 175.0/255.0, blue: 25.0/255.0, alpha: 1.0)
    var selectionPrimaryBorderWidth: CGFloat = 3.0
    var selectedPrimary = false
    func selectPrimary() {
        updateBorder()
        borderView?.layer?.borderWidth = selectionPrimaryBorderWidth
        borderView?.layer?.borderColor = selectionPrimaryBorderColor.cgColor
        
        selectedPrimary = true
        selectedSecondary = false
    }
    
    
    let selectionSecondaryBorderColor = NSColor(red: 52.0/255.0, green: 149.0/255.0, blue: 242.0/255.0, alpha: 1.0)
    var selectionSecondaryBorderWidth: CGFloat = 3.0
    var selectedSecondary = false
    func selectSecondary() {
        updateBorder()
        borderView?.layer?.borderWidth = selectionSecondaryBorderWidth
        borderView?.layer?.borderColor = selectionSecondaryBorderColor.cgColor
        
        selectedSecondary = true
        selectedPrimary = false
    }
    
    
    func deselectPrimary() {
        if selectedPrimary {
            updateBorder()
            selectedPrimary = false
        }
    }
    
    
    func deselectSecondary() {
        if selectedSecondary {
            updateBorder()
            selectedSecondary = false
        }
    }
}
