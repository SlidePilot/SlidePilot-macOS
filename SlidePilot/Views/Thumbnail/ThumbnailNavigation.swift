//
//  ThumbnailNavigation.swift
//  SlidePilot
//
//  Created by Pascal Braband on 31.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa
import PDFKit


protocol ThumbnailNavigationDelegate: NSObject {
    func didSelectThumbnail(at index: Int)
}


class ThumbnailNavigation: NSView {
    
    unowned var delegate: ThumbnailNavigationDelegate?
    
    // Views
    var searchContainer: NSView!
    var searchField: NSTextField!
    
    var thumbnails: [ThumbnailView] = [ThumbnailView]()
    var scrollView: NSScrollView!
    var documentView: NSView!
    

    // Document and PDF
    var document: PDFDocument? {
        didSet {
            updateView()
        }
    }
    
    private(set) var currentSelection: Int = 0
    
    var displayMode: PDFPageView.DisplayMode = .full {
        didSet {
            updateView()
        }
    }
    
    
    // Colors
    let mainBackgroundColor = NSColor(white: 0.12, alpha: 1.0)
    let searchBackgroundColor = NSColor.black
        
    
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    
    
    // MARK: - UI Setup
    
    private func setup() {
        self.wantsLayer = true
        self.layer?.backgroundColor = mainBackgroundColor.cgColor
        
        // Shadow
        self.shadow = NSShadow()
        self.layer?.shadowOpacity = 1.0
        self.layer?.shadowColor = .black
        self.layer?.shadowOffset = NSMakeSize(0, 0)
        self.layer?.shadowRadius = 20
        
        // Search Field Container
        searchContainer = NSView(frame: .zero)
        searchContainer.translatesAutoresizingMaskIntoConstraints = false
        searchContainer.wantsLayer = true
        searchContainer.layer?.backgroundColor = searchBackgroundColor.cgColor
        self.addSubview(searchContainer)
        self.addConstraints([NSLayoutConstraint(item: searchContainer!, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0),
                             NSLayoutConstraint(item: searchContainer!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
                             NSLayoutConstraint(item: searchContainer!, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0),
                             NSLayoutConstraint(item: searchContainer!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40.0)])
        
        // Search Field
        searchField = NSTextField(frame: .zero)
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.isBordered = false
        searchField.isBezeled = true
        searchField.bezelStyle = .roundedBezel
        searchField.isEditable = true
        searchField.isSelectable = true
        searchField.cell?.isScrollable = true
        searchField.alignment = .right
        searchField.delegate = self
        searchContainer.addSubview(searchField)
        searchContainer.addConstraints([
            NSLayoutConstraint(item: searchField!, attribute: .right, relatedBy: .equal, toItem: searchContainer!, attribute: .right, multiplier: 1.0, constant: -15.0),
            NSLayoutConstraint(item: searchField!, attribute: .centerY, relatedBy: .equal, toItem: searchContainer!, attribute: .centerY, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: searchField!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50.0)])
        
        // Scroll View
        scrollView = NSScrollView(frame: .zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.drawsBackground = false
        self.addSubview(scrollView)
        self.addConstraints([NSLayoutConstraint(item: scrollView!, attribute: .top, relatedBy: .equal, toItem: searchContainer, attribute: .bottom, multiplier: 1.0, constant: 0.0),
                             NSLayoutConstraint(item: scrollView!, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0),
                             NSLayoutConstraint(item: scrollView!, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0),
                             NSLayoutConstraint(item: scrollView!, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0)])
        
        // Scroll View's Document View
        documentView = FlippedView(frame: .zero)
        documentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.documentView = documentView
        scrollView.contentView.addConstraints([NSLayoutConstraint(item: documentView!, attribute: .top, relatedBy: .equal, toItem: scrollView.contentView, attribute: .top, multiplier: 1.0, constant: 19.0),
                                               NSLayoutConstraint(item: documentView!, attribute: .right, relatedBy: .equal, toItem: scrollView.contentView, attribute: .right, multiplier: 1.0, constant: -15.0),
                                               NSLayoutConstraint(item: documentView!, attribute: .left, relatedBy: .equal, toItem: scrollView.contentView, attribute: .left, multiplier: 1.0, constant: 0.0)])
        
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
    }
    
    
    override func viewWillDraw() {
        self.thumbnails.forEach({ $0.updateBorder() })
    }
    
    
    
    
    // MARK: - UI Update
    
    private func clearScrollView() {
        thumbnails.forEach({ $0.removeFromSuperview() })
        thumbnails = [ThumbnailView]()
    }
    
    
    private func updateView() {
        clearScrollView()
        
        guard document != nil else { return }
        var previousThumbnail: ThumbnailView? = nil

        // Loop through all pages
        for i in 0...document!.pageCount-1 {

            // Add thumbnail view to document view of scroll view
            let thumbnail = ThumbnailView(frame: .zero)
            
            // Setup thumbnail view
            thumbnail.document = document
            thumbnail.page.displayMode = self.displayMode
            thumbnail.page.currentPage = i
            thumbnail.label.stringValue = "\(i+1)"
            thumbnail.delegate = self
            
            // Setup layout
            thumbnail.translatesAutoresizingMaskIntoConstraints = false
            documentView.addSubview(thumbnail)
            documentView.addConstraints([
                NSLayoutConstraint(item: thumbnail, attribute: .left, relatedBy: .equal, toItem: documentView!, attribute: .left, multiplier: 1.0, constant: 5.0),
                NSLayoutConstraint(item: thumbnail, attribute: .right, relatedBy: .equal, toItem: documentView!, attribute: .right, multiplier: 1.0, constant: 0.0)])

            // Adjust thumbnail height to fit the images height if possible
            if let pageFrame = thumbnail.document?.page(at: thumbnail.page.currentPage)?.bounds(for: .cropBox) {
                // ratioFix is just try and error value
                let ratioFix: CGFloat = 60.0
                let aspectRatio = pageFrame.height / (pageFrame.width + ratioFix)
                documentView.addConstraint(NSLayoutConstraint(item: thumbnail, attribute: .height, relatedBy: .equal, toItem: thumbnail, attribute: .width, multiplier: aspectRatio, constant: 0))
            } else {
                documentView.addConstraint(NSLayoutConstraint(item: thumbnail, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100))
            }
            
            
            // Add top constraint
            if previousThumbnail == nil {
                documentView.addConstraint(NSLayoutConstraint(item: thumbnail, attribute: .top, relatedBy: .equal, toItem: documentView!, attribute: .top, multiplier: 1.0, constant: 20.0))
            } else {
                documentView.addConstraint(NSLayoutConstraint(item: thumbnail, attribute: .top, relatedBy: .equal, toItem: previousThumbnail!, attribute: .bottom, multiplier: 1.0, constant: 30.0))
            }
            previousThumbnail = thumbnail
            thumbnails.append(thumbnail)
        }

        // Set last constraint
        guard previousThumbnail != nil else { return }
        documentView.addConstraint(NSLayoutConstraint(item: previousThumbnail!, attribute: .bottom, relatedBy: .equal, toItem: documentView, attribute: .bottom, multiplier: 1.0, constant: -15.0))
    }
    
    
    
    
    // MARK: - Thumbnail UI Manipulation
    
    
    /**
     Selects the thumbnail at the given index.
     
     - parameters:
        - index: Can be any `Int`, if the index is too high, the last thumbnail will be selected.
        - scrollVisible: If set to true, the scroll view will scroll to make the thumbnail visible.
     */
    public func selectThumbnail(at index: Int, scrollVisible: Bool) {
        // Get thumbnail for index
        let safeIndex = min(index, thumbnails.count-1)
        guard thumbnails.indices.contains(safeIndex) else { return }
        let thumbnail = thumbnails[safeIndex]
        
        // Removed highlight and selection from other thumbnails
        cleanHighlight()
        thumbnails.forEach({ $0.deselectPrimary() })
        
        // Select the new thumbnail
        thumbnail.selectPrimary()
        
        // Update the searchField (use the unsafe index)
        // (It might happen, that the user enters a too high index, then his text will be replaced immideately, not nice)
        searchField.stringValue = "\(index+1)"
        
        // Scroll to top of thumbnail if flag is set
        if scrollVisible {
            scrollView.contentView.scroll(to: NSPoint(x: 0, y: thumbnail.frame.minY))
        }
        
        // Update the indicator of the currently selected thumbnail
        currentSelection = safeIndex
    }
    
    
    private(set) var currentHighlight: Int?
    
    /**
    Highlight the thumbnail at index if found and scrolls to its position.
    
    - parameters:
       - index: Can be any `Int`, if the index is too high, the last thumbnail will be selected.
        - scrollVisible: If set to true, the scroll view will scroll to make the thumbnail visible.
    */
    private func highlightThumbnail(at index: Int, scrollVisible: Bool) {
        // Get thumbnail for index
        let safeIndex = min(index, thumbnails.count-1)
        guard thumbnails.indices.contains(safeIndex) else { return }
        let thumbnail = thumbnails[safeIndex]
        
        // Removed highlight from other thumbnails
        cleanHighlight()
        
        // Highlight the new thumbnail
        thumbnail.selectSecondary()
        
        // Scroll to top of thumbnail if flag is set
        if scrollVisible {
            scrollView.contentView.scroll(to: NSPoint(x: 0, y: thumbnail.frame.minY))
        }
        
        // Update the indicator of the currently highlighted thumbnail
        currentHighlight = safeIndex
    }
    
    
    private func cleanHighlight() {
        thumbnails.forEach({ $0.deselectSecondary() })
        currentHighlight = nil
    }
}




extension ThumbnailNavigation: ThumbnailViewDelegate {
    
    func didSelect(thumbnail: ThumbnailView) {
        guard let index = thumbnails.firstIndex(of: thumbnail) else { return }
        selectThumbnail(at: index, scrollVisible: false)
        delegate?.didSelectThumbnail(at: index)
    }
}




extension ThumbnailNavigation: NSTextFieldDelegate {
    
    func controlTextDidEndEditing(_ obj: Notification) {
        // Select currently highlighted thumbnail
        guard let index = currentHighlight else { return }
        selectThumbnail(at: index, scrollVisible: true)
        delegate?.didSelectThumbnail(at: index)
    }
    
    func controlTextDidChange(_ obj: Notification) {
        guard let textField = obj.object as? NSTextField else { return }
        if textField == searchField {
            // If numbers were entered, find page with this number
            if let index = Int(textField.stringValue) {
                highlightThumbnail(at: index-1, scrollVisible: true)
            }
            // Otherwise search for the string one the pages
            else {
               // TODO: Asynchronously find text in PDF using beginFindString
            }
        }
    }
}




extension ThumbnailNavigation: SlideArrangementDelegate {
    
    func didSelectSlide(at index: Int) {
        selectThumbnail(at: index, scrollVisible: true)
    }
    
    
    func didChangeDocument(_ document: PDFDocument?) {
        self.document = document
    }
    
    
    func didChangeDisplayMode(_ mode: PDFPageView.DisplayMode) {
        self.displayMode = mode
    }
}




class FlippedView: ClipfreeView {
    override var isFlipped: Bool {
        return true
    }
}
