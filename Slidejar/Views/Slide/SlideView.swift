//
//  SlideView.swift
//  Slidejar
//
//  Created by Pascal Braband on 23.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class SlideView: NSView {
    
    var label: NSTextField?
    var page: PDFPageView?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }

    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    
    func setupView() {
        label = NSTextField(frame: .zero)
        label!.font = NSFont.systemFont(ofSize: 15.0, weight: .regular)
        label!.alignment = .center
        label!.isEditable = false
        label!.isSelectable = false
        label!.isBordered = false
        label!.drawsBackground = false
        
        label!.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label!)
        self.addConstraints([NSLayoutConstraint(item: label!, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0),
                             NSLayoutConstraint(item: label!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
                             NSLayoutConstraint(item: label!, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0),
                             NSLayoutConstraint(item: label!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 20.0)])
        
        page = PDFPageView(frame: .zero)
        page!.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(page!)
        self.addConstraints([NSLayoutConstraint(item: page!, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0),
                             NSLayoutConstraint(item: page!, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0),
                             NSLayoutConstraint(item: page!, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0), NSLayoutConstraint(item: page!, attribute: .top, relatedBy: .equal, toItem: label!, attribute: .bottom, multiplier: 1.0, constant: 10.0)])
        page?.setContentCompressionResistancePriority(NSLayoutConstraint.Priority(rawValue: 250.0), for: .horizontal)
        page?.setContentCompressionResistancePriority(NSLayoutConstraint.Priority(rawValue: 250.0), for: .vertical)
    }
}
