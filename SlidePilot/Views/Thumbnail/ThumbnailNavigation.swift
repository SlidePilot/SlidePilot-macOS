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
    
    weak var delegate: ThumbnailNavigationDelegate?

    var searchContainer: NSView!
    var searchField: NSTextField!
    
    var scrollView: NSScrollView!
    var tableView: NSTableView!
    
    // Colors
    let mainBackgroundColor = NSColor(white: 0.12, alpha: 1.0)
    let searchBackgroundColor = NSColor.black
    
    var displayMode: PDFPageView.DisplayMode = .full {
        didSet {
            tableView.reloadData()
        }
    }
    
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    
    func setup() {
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
        scrollView = NSScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.drawsBackground = false
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        self.addSubview(scrollView)
        self.addConstraints([NSLayoutConstraint(item: scrollView!, attribute: .top, relatedBy: .equal, toItem: searchContainer, attribute: .bottom, multiplier: 1.0, constant: 0.0),
                             NSLayoutConstraint(item: scrollView!, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0),
                             NSLayoutConstraint(item: scrollView!, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0),
                             NSLayoutConstraint(item: scrollView!, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0)])
        
        // Table View
        tableView = NSTableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.headerView = nil
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        scrollView.documentView = tableView
        tableView.usesAutomaticRowHeights = true
        tableView.intercellSpacing = NSSize(width: 0.0, height: 20.0)
        tableView.selectionHighlightStyle = .none
        tableView.rowHeight = 50.0
        
        let col = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "col"))
        col.minWidth = 100
        tableView.addTableColumn(col)
        
        self.addConstraints([NSLayoutConstraint(item: tableView!, attribute: .top, relatedBy: .equal, toItem: scrollView!, attribute: .bottom, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: tableView!, attribute: .right, relatedBy: .equal, toItem: scrollView!, attribute: .right, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: tableView!, attribute: .left, relatedBy: .equal, toItem: scrollView!, attribute: .left, multiplier: 1.0, constant: 0.0)])
        
        // Subscribe to page changes
        PageController.subscribe(target: self, action: #selector(pageDidChange(_:)))
        
        // Subscribe to document changes
        DocumentController.subscribe(target: self, action: #selector(documentDidChange(_:)))
    }
    
    
    
    
    // MARK: - Thumbnail UI Manipulation
    
    private(set) var currentSelection: Int = -1
    
    /**
     Selects the thumbnail at the given index.
     
     - parameters:
        - index: Can be any `Int`, if the index is too high, the last thumbnail will be selected.
        - scrollVisible: If set to true, the scroll view will scroll to make the thumbnail visible.
     */
    public func selectThumbnail(at index: Int, scrollVisible: Bool) {
        // Get thumbnail for index (prevent selecting too high index and prevent selecting when there are no pages at all)
        let pageCount = DocumentController.pageCount
        guard pageCount > 0 else { return }
        // Lower bound 0, upper bound pageCount
        let safeIndex = max(min(index, pageCount-1), 0)
        
        // Remove highlight from thumbnail
        cleanHighlight()
        
        // Save previous selection index
        let previousSelection = currentSelection
        
        // Update previous (remove selection) and current (add selection) thumbnail cells
        currentSelection = safeIndex
        if previousSelection >= 0,
            let previousCell = tableView.view(atColumn: 0, row: previousSelection, makeIfNecessary: true),
            let previousThumbnail = previousCell.subviews[0] as? ThumbnailView {
            DispatchQueue.main.async {
                previousThumbnail.deselectPrimary()
            }
        }
        
        if let currentCell = tableView.view(atColumn: 0, row: currentSelection, makeIfNecessary: true),
            let currentThumbnail = currentCell.subviews[0] as? ThumbnailView {
            DispatchQueue.main.async {
                currentThumbnail.selectPrimary()
            }
        }
        
        // Update the searchField (use the unsafe index)
        // (It might happen, that the user enters a too high index, then his text will be replaced immideately, not nice)
        searchField.stringValue = "\(index+1)"
        
        // Scroll to top of thumbnail if flag is set
        if scrollVisible {
            tableView.scrollRowToVisible(safeIndex)
        }
    }
    
    
    private(set) var currentHighlight: Int?
    
    /**
    Highlight the thumbnail at index if found and scrolls to its position.
    
    - parameters:
       - index: Can be any `Int`, if the index is too high, the last thumbnail will be selected.
        - scrollVisible: If set to true, the scroll view will scroll to make the thumbnail visible.
    */
    private func highlightThumbnail(at index: Int, scrollVisible: Bool) {
        // Get thumbnail for index (prevent selecting too high index and prevent selecting when there are no pages at all)
        let pageCount = DocumentController.pageCount
        guard pageCount > 0 else { return }
        // Lower bound 0, upper bound pageCount
        let safeIndex = max(min(index, pageCount-1), 0)
        
        // Update previous (remove highlight) and current (add highlight) thumbnail cells
        cleanHighlight(restoreSelection: true)
        
        currentHighlight = safeIndex
        if let current = currentHighlight,
            let currentCell = tableView.view(atColumn: 0, row: current, makeIfNecessary: true),
            let currentThumbnail = currentCell.subviews[0] as? ThumbnailView {
            DispatchQueue.main.async {
                currentThumbnail.selectSecondary()
            }
        }
        
        // Scroll to top of thumbnail if flag is set
        if scrollVisible && currentHighlight != nil {
            tableView.scrollRowToVisible(currentHighlight!)
        }
    }
    
    
    /**
     Removes highlight from `currentHighlight`.
     
     - parameters:
        - restoreSelection: Selects thumbnail as primary, if it was primary before
     */
    private func cleanHighlight(restoreSelection: Bool = false) {
        if let current = currentHighlight,
            // Deselect secondary from current highlight
            let currentCell = tableView.view(atColumn: 0, row: current, makeIfNecessary: true),
            let currentThumbnail = currentCell.subviews[0] as? ThumbnailView {
            DispatchQueue.main.async {
                // If highlight was on current selection, then select again
                if restoreSelection, current == self.currentSelection {
                    currentThumbnail.selectPrimary()
                }
                // Just remove highlight otherwise
                else {
                    currentThumbnail.deselectSecondary()
                }
            }
        }
        currentHighlight = nil
    }
    
    
    
    
    // MARK: - Control Handlers
    
    @objc private func pageDidChange(_ notification: Notification) {
        selectThumbnail(at: PageController.currentPage, scrollVisible: false)
    }
    
    
    @objc func documentDidChange(_ notification: Notification) {
        tableView.reloadData()
    }
    
}




extension ThumbnailNavigation: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let thumbnail = ThumbnailView(frame: .zero)
        thumbnail.translatesAutoresizingMaskIntoConstraints = false
        thumbnail.page.setDocument(DocumentController.document, mode: displayMode, at: row)
        thumbnail.label.stringValue = "\(row+1)"
        
        let cell = NSTableCellView()
        cell.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(thumbnail)
        cell.addConstraints([NSLayoutConstraint(item: thumbnail, attribute: .left, relatedBy: .equal, toItem: cell, attribute: .left, multiplier: 1.0, constant: 0.0),
                             NSLayoutConstraint(item: thumbnail, attribute: .top, relatedBy: .equal, toItem: cell, attribute: .top, multiplier: 1.0, constant: 0.0),
                             NSLayoutConstraint(item: thumbnail, attribute: .right, relatedBy: .equal, toItem: cell, attribute: .right, multiplier: 1.0, constant: -20.0),
                             NSLayoutConstraint(item: thumbnail, attribute: .bottom, relatedBy: .equal, toItem: cell, attribute: .bottom, multiplier: 1.0, constant: 0.0)])
        
        // Adjust thumbnail height to fit the images height if possible
        if let pageFrame = thumbnail.page.pdfDocument?.page(at: thumbnail.page.currentPage)?.bounds(for: .cropBox) {
            // ratioFix is just try and error value
            let ratioFix: CGFloat = 60.0
            let aspectRatio = pageFrame.height / (pageFrame.width + ratioFix)
            cell.addConstraint(NSLayoutConstraint(item: thumbnail, attribute: .height, relatedBy: .equal, toItem: thumbnail, attribute: .width, multiplier: aspectRatio, constant: 0))
        } else {
            cell.addConstraint(NSLayoutConstraint(item: thumbnail, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100))
        }
        
        return cell
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 120.0
    }
    
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let tableView = notification.object as? NSTableView else { return }
        PageController.selectPage(at: tableView.selectedRow, sender: self)
    }
    
}




extension ThumbnailNavigation: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return DocumentController.pageCount
    }
}



extension ThumbnailNavigation: NSTextFieldDelegate {
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if (commandSelector == #selector(NSResponder.insertNewline(_:))) {
            // Select currently highlighted thumbnail on ENTER
            guard let index = currentHighlight else { return false }
            PageController.selectPage(at: index, sender: self)
            return true
        }
        return false
    }
    
    func controlTextDidChange(_ obj: Notification) {
        guard let textField = obj.object as? NSTextField else { return }
        if textField == searchField {
            // If numbers were entered, find page with this number
            if let index = Int(textField.stringValue) {
                highlightThumbnail(at: index-1, scrollVisible: true)
            }
            // Otherwise clean highlight
            else {
                cleanHighlight(restoreSelection: true)
            }
            // TODO: If not a number, search for text on pages
            // Asynchronously find text in PDF using beginFindString
        }
    }
}





extension ThumbnailNavigation: SlideArrangementDelegate {    
    
    func didChangeDisplayMode(_ mode: PDFPageView.DisplayMode) {
        self.displayMode = mode
        selectThumbnail(at: currentSelection, scrollVisible: true)
    }
}
