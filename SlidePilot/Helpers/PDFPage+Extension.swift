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
    
    
    /**
     Extract a String from the PDF Page. Use this only for extracting text from the additional notes page
     */
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
}

// Read the file specification directly: PDFKit's annotation values do not
// reliably expose embedded file streams.
extension PDFPage {
    func movieResources() -> [(bounds: CGRect, file: CGPDFObjectRef)] {
        guard let page = pageRef, let dictionary = page.dictionary else { return [] }
        var annotations: CGPDFArrayRef?
        guard CGPDFDictionaryGetArray(dictionary, "Annots", &annotations), let array = annotations else { return [] }
        var result = [(bounds: CGRect, file: CGPDFObjectRef)]()
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
            result.append((CGRect(x: min(values[0], values[2]), y: min(values[1], values[3]),
                                  width: abs(values[2] - values[0]), height: abs(values[3] - values[1])), specification))
        }
        return result
    }
}

/// Keeps extracted movies alive and gives both windows the same resource URL.
final class PDFMovieFiles {
    static let shared = PDFMovieFiles()
    private var document: PDFDocument?
    private var directory: URL?
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
        guard let base = document?.documentURL?.deletingLastPathComponent() else { return nil }
        return base.appendingPathComponent(path)
    }
}
