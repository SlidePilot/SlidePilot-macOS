//
//  SlideArrangementView.swift
//  Slidejar
//
//  Created by Pascal Braband on 23.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa
import PDFKit

class SlideArrangementView: NSView {
    
    private var splitView: NSSplitView?
    private var leftContainer: NSView?
    private var rightContainer: NSView?
    
    private var currentSlideView: SlideView?
    private var nextSlideView: SlideView?
    private var notesSlideView: SlideView?
    
    private let padding: CGFloat = 0.05
    private let distributionRatio: CGFloat = 0.6
    
    var pdfDocument: PDFDocument? {
        didSet {
            updateView()
        }
    }

    var displayNodes: Bool = false {
        didSet {
            updateView()
        }
    }
    
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    
    private func setupView() {
        splitView = NSSplitView(frame: self.frame)
        splitView!.dividerStyle = .thin
        splitView!.isVertical = true
        
        splitView!.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(splitView!)
        self.addConstraints([NSLayoutConstraint(item: splitView!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
                             NSLayoutConstraint(item: splitView!, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0),
                             NSLayoutConstraint(item: splitView!, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0),
                             NSLayoutConstraint(item: splitView!, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0)])
        
        leftContainer = NSView(frame: .zero)
        splitView!.addSubview(leftContainer!)
        
        rightContainer = NSView(frame: .zero)
        splitView!.addSubview(rightContainer!)
        
        // Set min width for containers
        leftContainer!.addConstraint(NSLayoutConstraint(item: leftContainer!, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 300.0))
        rightContainer!.addConstraint(NSLayoutConstraint(item: rightContainer!, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 300.0))
        
        splitView!.adjustSubviews()
        updateView()
    }
    
    
    private func updateView() {
        // Reset containers
        guard leftContainer != nil, rightContainer != nil else { return }
        leftContainer!.subviews.forEach({ $0.removeFromSuperview() })
        rightContainer!.subviews.forEach({ $0.removeFromSuperview() })
        
        switch displayNodes {
        case true:
            setupSlidesLayoutWithNotes()
        case false:
            setupSlidesLayoutDefault()
        }
        
        setupSlides(for: 0)
    }
    
    
    private func setupSlidesLayoutDefault() {
        guard leftContainer != nil, rightContainer != nil else { return }
        
        guard let path = Bundle.main.path(forResource: "slidedemo", ofType: "pdf") else { return }
        let url = URL(fileURLWithPath: path)
        guard let pdfDocument = PDFDocument(url: url) else { return }
        
        currentSlideView = SlideView(frame: .zero)
        currentSlideView!.translatesAutoresizingMaskIntoConstraints = false
        leftContainer?.addSubview(currentSlideView!)
        leftContainer?.addConstraints([
            NSLayoutConstraint(item: currentSlideView!, attribute: .centerX, relatedBy: .equal, toItem: leftContainer!, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: currentSlideView!, attribute: .height, relatedBy: .equal, toItem: currentSlideView!, attribute: .width, multiplier: 0.7, constant: 0.0),
            NSLayoutConstraint(item: currentSlideView!, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: leftContainer!, attribute: .top, multiplier: 1.0, constant: 20.0),
            NSLayoutConstraint(item: leftContainer!, attribute: .bottom, relatedBy: .greaterThanOrEqual, toItem: currentSlideView!, attribute: .bottom, multiplier: 1.0, constant: 20.0)])
        
        let currentCenterY = NSLayoutConstraint(item: currentSlideView!, attribute: .centerY, relatedBy: .equal, toItem: leftContainer!, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        currentCenterY.priority = NSLayoutConstraint.Priority(750.0)
        let currentWidth = NSLayoutConstraint(item: currentSlideView!, attribute: .width, relatedBy: .equal, toItem: leftContainer!, attribute: .width, multiplier: 0.9, constant: 0.0)
        currentWidth.priority = NSLayoutConstraint.Priority(260.0)
        leftContainer?.addConstraints([currentWidth, currentCenterY])
        
        
        nextSlideView = SlideView(frame: .zero)
        nextSlideView!.translatesAutoresizingMaskIntoConstraints = false
        rightContainer?.addSubview(nextSlideView!)
        rightContainer?.addConstraints([
            NSLayoutConstraint(item: nextSlideView!, attribute: .centerX, relatedBy: .equal, toItem: rightContainer!, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: nextSlideView!, attribute: .height, relatedBy: .equal, toItem: nextSlideView!, attribute: .width, multiplier: 0.7, constant: 0.0),
            NSLayoutConstraint(item: nextSlideView!, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: rightContainer!, attribute: .top, multiplier: 1.0, constant: 20.0),
            NSLayoutConstraint(item: rightContainer!, attribute: .bottom, relatedBy: .greaterThanOrEqual, toItem: nextSlideView!, attribute: .bottom, multiplier: 1.0, constant: 20.0)])
        
        let nextCenterY = NSLayoutConstraint(item: nextSlideView!, attribute: .centerY, relatedBy: .equal, toItem: rightContainer!, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        nextCenterY.priority = NSLayoutConstraint.Priority(750.0)
        let nextWidth = NSLayoutConstraint(item: nextSlideView!, attribute: .width, relatedBy: .equal, toItem: rightContainer!, attribute: .width, multiplier: 0.9, constant: 0.0)
        nextWidth.priority = NSLayoutConstraint.Priority(260.0)
        rightContainer?.addConstraints([nextWidth, nextCenterY])
        
        
        
        
        currentSlideView?.label?.stringValue = "Aktuelle Folie 4 / 20"
        currentSlideView?.page?.pdfDocument = pdfDocument
        nextSlideView?.label?.stringValue = "Nächste Folie"
        nextSlideView?.page?.pdfDocument = pdfDocument
        
        splitView?.setHoldingPriority(NSLayoutConstraint.Priority(270.0), forSubviewAt: 0)
        splitView?.setHoldingPriority(NSLayoutConstraint.Priority(270.0), forSubviewAt: 1)
    }
    
    
    private func setupSlidesLayoutWithNotes() {
        
    }
    
    
    private func setupSlides(for index: Int) {
        
    }
    
    
    func nextSlide() {

    }
    
    
    func previousSlide() {
        
    }
    
}
