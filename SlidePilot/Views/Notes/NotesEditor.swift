//
//  NotesEditor.swift
//  SlidePilot
//
//  Created by Pascal Braband on 28.05.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class NotesEditor: NSView {
    
    var label: NSTextField!
    var notesScrollView: NSScrollView!
    var notesTextView: NotesTextView!
    var finishButton: NSButton!

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    
    override func removeFromSuperview() {
        if !DisplayController.areNotesDisplayed || DisplayController.areDrawingToolsDisplayed {
            self.undoManager?.removeAllActions()
        }
        super.removeFromSuperview()
    }
    
    
    
    // MARK: - UI Setup/Update
    
    func setup() {
        // Setup info label for slide
        label = SlideInfoLabel(frame: .zero)
        
        label!.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label!)
        self.addConstraints([NSLayoutConstraint(item: label!, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
                             NSLayoutConstraint(item: label!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
                             NSLayoutConstraint(item: label!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 25.0)])
        
        
        // ScrollView setup
        notesScrollView = NSScrollView()
        let contentSize = notesScrollView.contentSize
        notesScrollView.borderType = .noBorder
        notesScrollView.hasVerticalScroller = true
        notesScrollView.hasHorizontalScroller = false
        notesScrollView.translatesAutoresizingMaskIntoConstraints = false
        notesScrollView.backgroundColor = NSColor(white: 0.1, alpha: 1.0)
        if #available(OSX 10.14, *) {
            notesScrollView.appearance = NSAppearance(named: .darkAqua)
        }
        
        
        // TextView setup
        notesTextView = NotesTextView(frame: .zero)
        notesTextView!.minSize = NSSize(width: 0, height: contentSize.height)
        notesTextView!.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        notesTextView!.isVerticallyResizable = true
        notesTextView!.isHorizontallyResizable = false
        notesTextView!.autoresizingMask = .width
        notesTextView!.responderDelegate = self
        
        // Text container setup
        notesTextView!.textContainer?.containerSize = NSSize(width: contentSize.width, height: CGFloat.greatestFiniteMagnitude)
        notesTextView?.textContainer?.widthTracksTextView = true
        
        // Additional appearance setup for notes text field
        notesTextView!.backgroundColor = NSColor(red: 0.17, green: 0.17, blue: 0.17, alpha: 1.0)
        notesTextView!.insertionPointColor = .white
        notesTextView!.textColor = .white
        
        notesScrollView.documentView = notesTextView
        self.addSubview(notesScrollView)
        
        self.addConstraints([
            NSLayoutConstraint(item: notesScrollView!, attribute: .top, relatedBy: .equal, toItem: label, attribute: .bottom, multiplier: 1.0, constant: 10.0),
            NSLayoutConstraint(item: notesScrollView!, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: notesScrollView!, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: notesScrollView!, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        ])
        
        
        // Add finish button
        finishButton = NSButton(frame: .zero)
        finishButton.translatesAutoresizingMaskIntoConstraints = false
        finishButton.bezelStyle = .rounded
        finishButton.title = NSLocalizedString("Finish", comment: "The title for the finish button.")
        finishButton.target = self
        finishButton.action = #selector(finishPressed(_:))
        finishButton.isHidden = true
        
        if #available(OSX 10.14, *) {
            finishButton.appearance = NSAppearance(named: .darkAqua)
        }
        
        self.addSubview(finishButton)
        self.addConstraints([
            NSLayoutConstraint(item: finishButton!, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: finishButton!, attribute: .centerY, relatedBy: .equal, toItem: label!, attribute: .centerY, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: finishButton!, attribute: .left, relatedBy: .greaterThanOrEqual, toItem: label!, attribute: .right, multiplier: 1.0, constant: 10.0)])
    }
    
    
    @objc func finishPressed(_ sender: NSButton) {
        notesTextView.window?.makeFirstResponder(nil)
    }
    
    
    func showFinishButton() {
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 0.1
            context.allowsImplicitAnimation = true
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            finishButton.isHidden = false
        }, completionHandler: nil)
    }
    
    
    func hideFinishButton() {
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 0.2
            context.allowsImplicitAnimation = true
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            finishButton.isHidden = true
        }, completionHandler: nil)
    }
}




extension NotesEditor: TextViewResponderDelegate {
    func didBecomeFirstResponder() {
        showFinishButton()
    }
    
    func didResignFirstResponder() {
        hideFinishButton()
    }
}
