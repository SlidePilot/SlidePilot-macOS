//
//  RenderCache.swift
//  SlidePilot
//
//  Created by Pascal Braband on 14.04.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Foundation
import PDFKit

class RenderCache {
    
    static var shared = RenderCache()
    
    class CacheKey: NSObject {
        let pageNumber: Int
        let displayMode: PDFPageView.DisplayMode
        /** The document the page was rendered from, so a render of a replaced (reloaded) document finishing late is never served. */
        let document: ObjectIdentifier?
        
        init(pageNumber: Int, displayMode: PDFPageView.DisplayMode, document: PDFDocument?) {
            self.pageNumber = pageNumber
            self.displayMode = displayMode
            self.document = document.map { ObjectIdentifier($0) }
        }
        
        override func isEqual(_ object: Any?) -> Bool {
            guard let other = object as? CacheKey else {
                return false
            }
            return self.pageNumber == other.pageNumber && self.displayMode == other.displayMode && self.document == other.document
        }
        
        override var hash: Int {
            return pageNumber.hashValue ^ displayMode.hashValue ^ (document?.hashValue ?? 0)
        }
    }
    
    /**
    Specifies 3 priorities, from fastest to slowest.

    - **Instantly**: Rendered before all other renders in queue.
    - **Fast**: Renders after Instantly priority.
    - **Normal**: Renders after Fast, but is faster than normal cache.
    */
    enum Priority {
        case fast, normal, background
        
        func toQoSClass() -> DispatchQoS.QoSClass {
            switch self {
            case .fast:
                return .userInitiated
            case .normal:
                return .utility
            case .background:
                return .background
            }
        }
    }
    
    
    /** When a page is request, +- preRenderRange pages will be submitted as a prerender task. */
    private let preRenderRangeDelta: Int = 50
    
    public var document: PDFDocument? {
        didSet {
            // Only render again when value truly changed
            if oldValue != self.document {
                startPreRender()
            }
        }
    }
    
    /** Stores pre-rendered pages. Assigns page index to page data. */
    private var cache: NSCache = NSCache<CacheKey, NSImage>()
    
    
    init(cacheLimit: Int = 200) {
        cache.countLimit = cacheLimit
    }
    
    
    /**
     Returns the given page for any PDF document.
     */
    public func getPage(at index: Int, for document: PDFDocument, mode: PDFPageView.DisplayMode, priority: Priority) -> NSImage? {
        if document != self.document {
            self.document = document
        }
        return getPage(at: index, mode: mode, priority: priority)
    }
    
    
    /**
     Returns the given page of the PDF document, which is saved under `document`.
     Either from cache or renders the page.
    */
    private func getPage(at index: Int, mode: PDFPageView.DisplayMode, priority: Priority) -> NSImage? {
        // Check if page at index exist
        guard let page = document?.page(at: index) else { return nil }
        
        // Set crop box
        let pageRect = mode.getBounds(for: page)
        page.setBounds(pageRect, for: .cropBox)
        
        // Start pre rendering in a range +-50 pages from the requested pages
        if priority == .fast {
            let preRenderRange = index-preRenderRangeDelta...index+preRenderRangeDelta
            startRenderTask(pages: preRenderRange, displayMode: mode)
        }
        
        // Check if page is cached
        if let cachedPage = self.cache.object(forKey: CacheKey(pageNumber: index, displayMode: mode, document: document)) {
            // Return cached page
            return cachedPage
        } else {
            // Render page instantly, save in cache and return rendered page
            guard let pdfImage = createImage(from: page, mode: mode) else { return nil }
            self.cache.setObject(pdfImage, forKey: CacheKey(pageNumber: index, displayMode: mode, document: document))
            return pdfImage
        }
    }
    
    
    /**
     Prerenders the PDF document and saves it in the cache. This operation will override the old cache.
     */
    private func startPreRender() {
        guard let document = document else { return }
        
        // Start new prerender, clear cache first
        clearCache()
        
        DispatchQueue.global().async {
            self.render(pages: 0...min(document.pageCount-1, self.cache.countLimit), displayMode: .full)
        }
    }
    
    
    var renderTask: DispatchWorkItem?
    /**
     Starts a render task. Renders a given number of pages for a given display mode.
     
     If this method is called again, while another render task is still running, the old one will be cancelled.
     
     - parameters:
        - pages: A `ClosedRange<Int>` which specifies which pages should be rendered.
        - displayMode: The `PDFPageView.DisplayMode` in which the page should be rendered.
     */
    private func startRenderTask(pages: ClosedRange<Int>, displayMode mode: PDFPageView.DisplayMode) {
        // Cancel any previous render task
        renderTask?.cancel()
        
        // Create a new render task with the new range
        renderTask = DispatchWorkItem(block: {
            self.render(pages: pages, displayMode: mode)
        })
        
        // Execute the new task
        DispatchQueue.global(qos: .background).async(execute: renderTask!)
    }
    
    
    /**
     Renders a number of pages and saves them to cache.
     
     - parameters:
        - pages: A `ClosedRange<Int>` which specifies which pages should be rendered.
        - displayMode: The `PDFPageView.DisplayMode` in which the page should be rendered.
     */
    private func render(pages renderRange: ClosedRange<Int>, displayMode mode: PDFPageView.DisplayMode) {
        guard let document = document else { return }
        // Cut renderRange to document pages range
        let safeRange = max(0, renderRange.lowerBound)...min(document.pageCount-1, renderRange.upperBound)
        
        // Iterate through every page in the given prerender range
        for index in safeRange {
            
            // Render each page in prerender range in background and save them to cache
            DispatchQueue.global(qos: .background).async {
                
                // Only render if not already cached
                if !self.isCached(page: index, displayMode: mode, document: document) {
                    // Prerender page (of the document this render was started for)
                    guard let page = document.page(at: index) else { return }
                    guard let pdfImage = self.createImage(from: page, mode: mode) else { return }
                    
                    // Save to cache
                    self.cache.setObject(pdfImage, forKey: CacheKey(pageNumber: index, displayMode: mode, document: document))
                }
            }
        }
    }
    
    
    /**
     Checks if a given page for a given display mode is cached.
     */
    private func isCached(page index: Int, displayMode mode: PDFPageView.DisplayMode, document: PDFDocument) -> Bool {
        return self.cache.object(forKey: CacheKey(pageNumber: index, displayMode: mode, document: document)) != nil
    }
    
    
    /**
     Clears the rendered pages cache.
     */
    private func clearCache() {
        cache.removeAllObjects()
    }
    
    
    /**
     Draws image from PDF data
     */
    private func createImage(from page: PDFPage, mode: PDFPageView.DisplayMode = .full) -> NSImage? {
        // Set correct display bounds
        let pageRect = mode.getBounds(for: page)
        
        var drawRect = pageRect
        if page.rotation == 270 || page.rotation == 90 {
            drawRect = CGRect(x: pageRect.minX, y: pageRect.minY, width: pageRect.height, height: pageRect.width)
        }
        
        return NSImage(size: drawRect.size, flipped: false, drawingHandler: { (rect) -> Bool in
            guard let ctx = NSGraphicsContext.current?.cgContext else { return false }
            NSColor.white.set()
            ctx.fill(rect)
            
            // Draw page
            page.setBounds(pageRect, for: .cropBox)
            page.draw(with: .cropBox)
            
            return true
        })
    }
}
