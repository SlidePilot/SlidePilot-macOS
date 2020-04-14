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
    private var cache: NSCache = NSCache<NSNumber, NSData>()
    
    
    init(cacheLimit: Int = 200) {
        cache.countLimit = cacheLimit
    }
    
    
    /**
     Returns the given page for any PDF document.
     */
    public func getPage(at index: Int, for document: PDFDocument, priority: Priority, completion: @escaping (Data?) -> ()) {
        // FIXME: Page bounding rect as parameter and as key for cache
        if document != self.document {
            self.document = document
        }
        getPage(at: index, priority: priority, completion: completion)
    }
    
    
    /**
     Returns the given page of the PDF document, which is saved under `document`.
     Either from cache or renders the page.
    */
    private func getPage(at index: Int, priority: Priority, completion: @escaping (Data?) -> ()) {
        // Check if page at index exist
        guard let page = document?.page(at: index) else { completion(nil); return }
        
        // Render page async, save in cache and return rendered page
        DispatchQueue.global(qos: priority.toQoSClass()).sync {
            // Check if page is cached
            if let cachedPage = self.cache.object(forKey: index as NSNumber) {
                print("Cache")
                // Return cached page
                completion(cachedPage as Data?)
            } else {
                print("Render")
                // Render page
                guard let renderedPage = page.dataRepresentation else { completion(nil); return }
                self.cache.setObject(renderedPage as NSData, forKey: index as NSNumber)
                completion(renderedPage)
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
                    guard let renderedPage = doc.page(at: i)?.dataRepresentation else { return }
                    self.cache.setObject(renderedPage as NSData, forKey: i as NSNumber)
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
}
