//
//  PDFPage+Extension.swift
//  SlidePilot
//
//  Created by Pascal Braband on 29.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa
import PDFKit

extension PDFPage {
    
    
    /// Extract a String from the PDF Page. Use this only for extracting text from the additional notes page
    public func extractNotes() -> String {
        let pageRect = self.bounds(for: .cropBox)
        // Content rect ignores the note slides header
        let contentRect = NSRect(x: pageRect.minX, y: pageRect.minY, width: pageRect.width, height: pageRect.height*3/4)
        
        // Select everything in contentRect
        guard let selection = self.selection(for: contentRect) else { return "" }
        
        // Append each line in a string
        let lines = selection.selectionsByLine()
        var output = ""
        for line in lines {
            output += "\(line.string ?? "")\n"
        }
        
        return output.fixSpecialChars()
    }
    
    /// Calculates the translation ratio between a parent frame and a subsection frame.
    ///
    /// - Parameters:
    ///     - parent: The parent frame.
    ///     - section: A section of the parent frame.
    ///
    /// - Returns: The translation ratio (vector) for translations between parent and child.
    private func getTranslationRatio(parent: CGRect, section: CGRect) -> CGSize {
        let translation = CGSize(
            width: parent.width / section.width,
            height: parent.height / section.height)
        
        return translation
    }
    
    /// Translates a rectangle, representing a frame inside the `PDFPage` bounds into a relative frame, in regards to the presented section of the page, which is determined by the `DisplayMode`.
    ///
    /// - Parameters:
    ///     - bounds: The absolute frame inside the `PDFPage` bounds.
    ///     - displayMode: The `DisplayMode` which determines the section, in which the relative frame should be translated.
    ///
    /// - Returns: An `NSRect` which represents the given frame as a relative frame in the desired section of the page.
    func relativeBoundsInSection(for bounds: NSRect, displayMode: PDFPageView.DisplayMode) -> NSRect {
        // Full bounds of PDF page
        let pageBounds = PDFPageView.DisplayMode.full.getBounds(for: self)
        // Bounds of displayed section for PDF Page (regarding displayMode)
        let pageBoundsSection = displayMode.getBounds(for: self)
        
        // Calculate the relative bounds on PDF page from absolute bounds
        let relativeBounds = NSRect(x: (bounds.origin.x - pageBounds.origin.x) / pageBounds.width,
                                    y: (bounds.origin.y - pageBounds.origin.y) / pageBounds.height,
                                    width: bounds.width / pageBounds.width,
                                    height: bounds.height / pageBounds.height)
        
        // Calculate the relative bounds in section of PDF Page with regards to displayMode
        let translation = getTranslationRatio(parent: pageBounds, section: pageBoundsSection)
        let relativeBoundsInSection = NSRect(x: (relativeBounds.minX - pageBoundsSection.minX / pageBounds.width) * translation.width,
                                             y: (relativeBounds.minY - pageBoundsSection.minY / pageBounds.height) * translation.height,
                                             width: relativeBounds.width * translation.width,
                                             height: relativeBounds.height * translation.height)
        
        return relativeBoundsInSection
    }
    
    /// Translates a coordinate, representing a point inside the `PDFPage` bounds into a relative coordinate, in regards to the presented section of the page, which is determined by the `DisplayMode`.
    ///
    /// - Parameters:
    ///     - point: The absolute coordinate inside the `PDFPage` bounds.
    ///     - displayMode: The `DisplayMode` which determines the section, in which the relative coordinates should be translated.
    ///
    /// - Returns: An `NSPoint` which represents the given point as relative coordinates in the desired section of the page.
    func relativePointInSection(for point: NSPoint, displayMode: PDFPageView.DisplayMode) -> NSPoint {
        let relativeBounds = relativeBoundsInSection(
            for: NSRect(x: point.x, y: point.y, width: 0, height: 0),
            displayMode: displayMode)
        return NSPoint(x: relativeBounds.minX, y: relativeBounds.minY)
    }
    
    /// Translates a rectangle, representing a relative frame inside a section of the `PDFPage`, into an absolute frame on the full page, in regards to the presented section of the page, which is determined by the `DisplayMode`.
    ///
    /// - Parameters:
    ///     - bounds: The relative frame inside the section of the `PDFPage`.
    ///     - displayMode: The `DisplayMode` which determines the section, from which the relative frame should be translated.
    ///
    /// - Returns: An `NSRect` which represents the given frame as an absolute frame on the full page.
    func boundsFromRelativeInSection(for bounds: NSRect, displayMode: PDFPageView.DisplayMode) -> NSRect {
        // Full bounds of PDF page
        let pageBounds = PDFPageView.DisplayMode.full.getBounds(for: self)
        // Bounds of displayed section for PDF Page (regarding displayMode)
        let pageBoundsSection = displayMode.getBounds(for: self)
        
        // Calculate the relative bounds on the full PDF page, from the relative bounds from the section of the page
        let translation = getTranslationRatio(parent: pageBounds, section: pageBoundsSection)
        let relativeBoundsOnPage = NSRect(
            x: bounds.minX / translation.width + pageBoundsSection.minX / pageBounds.width,
            y: bounds.minY / translation.height + pageBoundsSection.minY / pageBounds.height,
            width: bounds.width / translation.width,
            height: bounds.height / translation.height)
        
        // Calculate absolute bounds on full PDF Page
        let boundsOnPage = NSRect(
            x: relativeBoundsOnPage.minX * pageBounds.width + pageBounds.origin.x,
            y: relativeBoundsOnPage.minY * pageBounds.height + pageBounds.origin.y,
            width: relativeBoundsOnPage.width * pageBounds.width,
            height: relativeBoundsOnPage.height * pageBounds.height)
        
        return boundsOnPage
    }
    
    /// Translates a coordinate, representing a relative point inside a section of the `PDFPage`, into an absolute coordinate on the full page, in regards to the presented section of the page, which is determined by the `DisplayMode`.
    ///
    /// - Parameters:
    ///     - point: The relative coordinate inside the section of the `PDFPage`.
    ///     - displayMode: The `DisplayMode` which determines the section, from which the relative point should be translated.
    ///
    /// - Returns: An `NSPoint` which represents the given point as an absolute coordinate on the full page.
    func pointFromRelativeInSection(for point: NSPoint, displayMode: PDFPageView.DisplayMode) -> NSPoint {
        let boundsOnPage = boundsFromRelativeInSection(
            for: NSRect(x: point.x, y: point.y, width: 0, height: 0),
            displayMode: displayMode)
        return NSPoint(x: boundsOnPage.minX, y: boundsOnPage.minY)
    }
}

// Read the file specification directly: PDFKit's annotation values do not
// reliably expose embedded file streams.
extension PDFPage {
    func movieResources() -> [(bounds: CGRect, file: CGPDFObjectRef, autostart: Bool, loop: Bool)] {
        guard let page = pageRef, let dictionary = page.dictionary else { return [] }
        var annotations: CGPDFArrayRef?
        guard CGPDFDictionaryGetArray(dictionary, "Annots", &annotations), let array = annotations else { return [] }
        let autostartTitles = Self.pageOpenMovieTitles(page: dictionary, annotations: array)
        var result = [(bounds: CGRect, file: CGPDFObjectRef, autostart: Bool, loop: Bool)]()
        for index in 0..<CGPDFArrayGetCount(array) {
            var annotation: CGPDFDictionaryRef?
            guard CGPDFArrayGetDictionary(array, index, &annotation), let entry = annotation else { continue }
            var movie: CGPDFDictionaryRef?
            var file: CGPDFObjectRef?
            var rect: CGPDFArrayRef?
            guard CGPDFDictionaryGetDictionary(entry, "Movie", &movie), let movieDictionary = movie,
                  CGPDFDictionaryGetObject(movieDictionary, "F", &file), let specification = file,
                  CGPDFDictionaryGetArray(entry, "Rect", &rect), let coordinates = rect,
                  CGPDFArrayGetCount(coordinates) == 4 else { continue }
            var values = [CGFloat](repeating: 0, count: 4)
            var valid = true
            for i in 0..<4 {
                var number: CGPDFReal = 0
                if !CGPDFArrayGetNumber(coordinates, i, &number) { valid = false }
                values[i] = CGFloat(number)
            }
            guard valid else { continue }
            var title: CGPDFStringRef?
            let autostart = CGPDFDictionaryGetString(entry, "T", &title) && title.flatMap(CGPDFStringCopyTextString)
                .map { autostartTitles.contains($0 as String) } == true
            // Beamer's `loop` and `repeat` options write /A << /Mode /Repeat >>.
            var activation: CGPDFDictionaryRef?
            var mode: UnsafePointer<CChar>?
            let loop = CGPDFDictionaryGetDictionary(entry, "A", &activation) && activation.map {
                CGPDFDictionaryGetName($0, "Mode", &mode) && mode.map { String(cString: $0) == "Repeat" } == true
            } == true
            result.append((CGRect(x: min(values[0], values[2]), y: min(values[1], values[3]),
                                  width: abs(values[2] - values[0]), height: abs(values[3] - values[1])), specification, autostart, loop))
        }
        return result
    }

    /// Titles of movies played when the page opens. Beamer's `\movie[autostart]`
    /// adds a hidden widget whose /AA /PO action plays the movie by its /T;
    /// the pdfmark route puts the same action in the page's /AA /O.
    private static func pageOpenMovieTitles(page: CGPDFDictionaryRef, annotations: CGPDFArrayRef) -> Set<String> {
        var titles = Set<String>()
        func collect(from owner: CGPDFDictionaryRef, key: String) {
            var additional: CGPDFDictionaryRef?
            var action: CGPDFDictionaryRef?
            var type: UnsafePointer<CChar>?
            var title: CGPDFStringRef?
            guard CGPDFDictionaryGetDictionary(owner, "AA", &additional), let triggers = additional,
                  CGPDFDictionaryGetDictionary(triggers, key, &action), let action = action,
                  CGPDFDictionaryGetName(action, "S", &type), let type = type, String(cString: type) == "Movie",
                  CGPDFDictionaryGetString(action, "T", &title), let title = title,
                  let text = CGPDFStringCopyTextString(title) else { return }
            var operation: UnsafePointer<CChar>?
            // An omitted /Operation means Play.
            if CGPDFDictionaryGetName(action, "Operation", &operation), let operation = operation,
               String(cString: operation) != "Play" { return }
            titles.insert(text as String)
        }
        collect(from: page, key: "O")
        for index in 0..<CGPDFArrayGetCount(annotations) {
            var annotation: CGPDFDictionaryRef?
            if CGPDFArrayGetDictionary(annotations, index, &annotation), let entry = annotation {
                collect(from: entry, key: "PO")
            }
        }
        return titles
    }
}

/// Keeps extracted movies alive and gives both windows the same resource URL.
final class PDFMovieFiles {
    static let shared = PDFMovieFiles()
    private var document: PDFDocument?
    private var directory: URL?
    /** File of the shown document, for documents loaded from memory (whose `documentURL` is `nil`). */
    var documentURL: URL?
    private var extracted = [CGPDFObjectRef: URL]()

    deinit { clear() }

    private func clear() {
        if let directory = directory { try? FileManager.default.removeItem(at: directory) }
        directory = nil
        extracted.removeAll()
    }

    func url(for object: CGPDFObjectRef, document: PDFDocument?) -> URL? {
        if self.document !== document {
            clear()
            self.document = document
        }
        if let cached = extracted[object] { return cached }
        func string(_ object: CGPDFObjectRef) -> String? {
            var value: CGPDFStringRef?
            guard CGPDFObjectGetValue(object, .string, &value), let value = value,
                  let text = CGPDFStringCopyTextString(value) else { return nil }
            return text as String
        }
        var name = string(object)
        var specification: CGPDFDictionaryRef?
        if CGPDFObjectGetValue(object, .dictionary, &specification), let spec = specification {
            for key in ["UF", "F"] {
                var value: CGPDFObjectRef?
                if CGPDFDictionaryGetObject(spec, key, &value), let value = value, let text = string(value) {
                    name = text
                    break
                }
            }
            var embedded: CGPDFDictionaryRef?
            if CGPDFDictionaryGetDictionary(spec, "EF", &embedded), let embedded = embedded {
                for key in ["UF", "F"] {
                    var stream: CGPDFStreamRef?
                    guard CGPDFDictionaryGetStream(embedded, key, &stream), let stream = stream else { continue }
                    var format = CGPDFDataFormat.raw
                    guard let data = CGPDFStreamCopyData(stream, &format) else { continue }
                    do {
                        if directory == nil {
                            let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
                            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
                            directory = folder
                        }
                        let ext = ((name ?? "movie.mp4") as NSString).pathExtension
                        let target = directory!.appendingPathComponent(UUID().uuidString).appendingPathExtension(ext.isEmpty ? "mp4" : ext)
                        try (data as Data).write(to: target, options: .atomic)
                        extracted[object] = target
                        return target
                    } catch { return nil }
                }
            }
        }
        guard let path = name, !path.isEmpty else { return nil }
        if let url = URL(string: path), let scheme = url.scheme,
           ["http", "https", "file"].contains(scheme.lowercased()) { return url }
        if (path as NSString).isAbsolutePath { return URL(fileURLWithPath: path) }
        guard let base = (document?.documentURL ?? documentURL)?.deletingLastPathComponent() else { return nil }
        return base.appendingPathComponent(path)
    }
}
