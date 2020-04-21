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
        
        init(pageNumber: Int, displayMode: PDFPageView.DisplayMode) {
            self.pageNumber = pageNumber
            self.displayMode = displayMode
        }
        
        override func isEqual(_ object: Any?) -> Bool {
            guard let other = object as? CacheKey else {
                return false
            }
            return self.pageNumber == other.pageNumber && self.displayMode == other.displayMode
        }
        
        override var hash: Int {
            return pageNumber.hashValue ^ displayMode.hashValue
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
    public func getPage(at index: Int, for document: PDFDocument, mode: PDFPageView.DisplayMode, priority: Priority, completion: @escaping (NSImage?) -> ()) {
        if document != self.document {
            self.document = document
        }
        getPage(at: index, mode: mode, priority: priority, completion: completion)
    }
    
    
    /**
     Returns the given page of the PDF document, which is saved under `document`.
     Either from cache or renders the page.
    */
    private func getPage(at index: Int, mode: PDFPageView.DisplayMode, priority: Priority, completion: @escaping (NSImage?) -> ()) {
        // Check if page at index exist
        guard let page = document?.page(at: index) else { completion(nil); return }
        
        // Render page async, save in cache and return rendered page
        DispatchQueue.global(qos: priority.toQoSClass()).sync {
            // Check if page is cached
            if let cachedPage = self.cache.object(forKey: CacheKey(pageNumber: index, displayMode: mode)) {
                print("Cache")
                // Return cached page
                completion(cachedPage)
            } else {
                print("Render")
                // Render page
                guard let pdfImage = createImage(from: page, mode: mode) else { return }
                self.cache.setObject(pdfImage, forKey: CacheKey(pageNumber: index, displayMode: mode))
                completion(pdfImage)
            }
        }
    }
    
    
    /**
     Prerenders the PDF document and saves it in the cache. This operation will override the old cache.
     */
    private func startPreRender() {
        // Only render if document not nil
        guard let doc = document else { return }
        
        // Start new prerender, clear cache first
        clearCache()
        
        DispatchQueue.global().async {
            // FIXME: Don't start at 0 everytime. Shift range to currently viewed pages
            for i in 0...min(doc.pageCount, self.cache.countLimit) {
                
                // Render each page (in bounds) in background and save them to cache
                DispatchQueue.global(qos: .background).async {
                    guard let page = doc.page(at: i) else { return }
                    guard let pdfImage = self.createImage(from: page, mode: .full) else { return }
                    self.cache.setObject(pdfImage, forKey: CacheKey(pageNumber: i, displayMode: .full))
                }
            }
        }
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
        let pageRect = getBoundsFor(mode: mode, pdfPage: page)
        page.setBounds(pageRect, for: .cropBox)
        
        // Generate data and image
        guard let pageData = page.dataRepresentation else { return nil }
        guard let imageRep = NSPDFImageRep(data: pageData) else { return nil }
        
        return NSImage(size: imageRep.size, flipped: false, drawingHandler: { (rect) -> Bool in
            guard let ctx = NSGraphicsContext.current?.cgContext else { return false }
            NSColor.white.set()
            ctx.fill(rect)

            imageRep.draw(in: rect)

            return true
        })
    }
    
    
    /**
     Returns correct bounds for `DisplayMode`.
     */
    private func getBoundsFor(mode: PDFPageView.DisplayMode, pdfPage: PDFPage) -> CGRect {
        switch mode {
        case .full:
            return pdfPage.bounds(for: .mediaBox)
        case .leftHalf:
            return CGRect(x: 0, y: 0, width: pdfPage.bounds(for: .mediaBox).width/2, height: pdfPage.bounds(for: .mediaBox).height)
        case .rightHalf:
            return CGRect(x: pdfPage.bounds(for: .mediaBox).width/2, y: 0, width: pdfPage.bounds(for: .mediaBox).width/2, height: pdfPage.bounds(for: .mediaBox).height)
        case .topHalf:
            return CGRect(x: 0, y: pdfPage.bounds(for: .mediaBox).height/2, width: pdfPage.bounds(for: .mediaBox).width, height: pdfPage.bounds(for: .mediaBox).height/2)
        case .bottomHalf:
            return CGRect(x: 0, y: 0, width: pdfPage.bounds(for: .mediaBox).width, height: pdfPage.bounds(for: .mediaBox).height/2)
        }
    }
}
