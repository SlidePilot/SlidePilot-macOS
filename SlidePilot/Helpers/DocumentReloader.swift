//
//  DocumentReloader.swift
//  SlidePilot
//
//  Reloads the presented PDF when it is rebuilt on disk, the way Skim does.
//

import Foundation
import PDFKit

/**
 Loads PDF documents from memory instead of from the file.

 A `PDFDocument(url:)` reads its pages lazily from the file, so it breaks when the file is rewritten
 while it is shown. A document created from the file's bytes is unaffected by later changes on disk.
 */
enum PDFLoader {

    /** Loads the document at `url` for opening it. Returns the document and the bytes it was read from. */
    static func openDocument(at url: URL) -> (document: PDFDocument, data: Data)? {
        guard let data = try? Data(contentsOf: url),
              let document = PDFDocument(data: data) else { return nil }
        return (document, data)
    }


    /**
     Loads the document at `url` only if it is a complete, valid PDF that did not change while being
     read. Returns `nil` for anything else, e.g. a file that is half-written, truncated by a failed
     build, empty, missing, locked, or without pages.
     */
    static func loadCompleteDocument(at url: URL) -> (document: PDFDocument, data: Data)? {
        guard let before = FileObserver.Fingerprint(path: url.path),
              let data = try? Data(contentsOf: url),
              FileObserver.Fingerprint(path: url.path) == before,
              isCompletePDF(data),
              let document = PDFDocument(data: data),
              !document.isLocked,
              document.pageCount > 0,
              document.page(at: document.pageCount - 1) != nil else { return nil }
        return (document, data)
    }


    /** Checks for the PDF header at the start and the end-of-file marker at the end (as Skim does). */
    static func isCompletePDF(_ data: Data) -> Bool {
        guard data.count > 16 else { return false }
        let window = 1024
        let head = data.prefix(window)
        let tail = data.suffix(window)
        return head.range(of: Data("%PDF-".utf8)) != nil
            && tail.range(of: Data("%%EOF".utf8)) != nil
    }
}




/**
 Watches a PDF file and delivers a new document whenever a complete, valid new version is on disk.

 Anything else is ignored silently: while the file is missing, half-written or broken, the caller
 keeps showing the old document. After an invalid version the file is checked again every
 `retryInterval` for at most `retryDuration`, then the reloader waits quietly for the next change.
 Loads run one at a time on a background queue; a change that arrives during a load supersedes it.
 */
class DocumentReloader {

    private let url: URL
    private let retryInterval: TimeInterval
    private let retryDuration: TimeInterval
    private let callbackQueue: DispatchQueue
    private let onReload: (PDFDocument) -> Void

    private let loadQueue = DispatchQueue(label: "SlidePilot.DocumentReloader", qos: .userInitiated)
    private var observer: FileObserver?

    /** Number of the latest change; only accessed on `loadQueue`. */
    private var generation = 0
    /** Bytes of the version shown (or last delivered); only accessed on `loadQueue`. */
    private var shownData: Data?

    /** Set on `callbackQueue`; a cancelled reloader delivers nothing more. */
    private var isCancelled = false


    /**
     - parameters:
        - url: The PDF file to watch.
        - shownData: The bytes of the document currently shown, if known. A change that leaves the content identical is not delivered.
        - onReload: Called on `callbackQueue` with each new valid version.
     */
    init(url: URL, shownData: Data? = nil,
         settleInterval: TimeInterval = 0.4, pollInterval: TimeInterval = 2.0,
         retryInterval: TimeInterval = 0.5, retryDuration: TimeInterval = 15.0,
         callbackQueue: DispatchQueue = .main,
         onReload: @escaping (PDFDocument) -> Void) {
        self.url = url
        self.shownData = shownData
        self.retryInterval = retryInterval
        self.retryDuration = retryDuration
        self.callbackQueue = callbackQueue
        self.onReload = onReload

        observer = FileObserver(URL: url, settleInterval: settleInterval, pollInterval: pollInterval) { [weak self] in
            self?.fileDidChange()
        }
    }


    /** Stops watching. Must be called on `callbackQueue`. */
    func cancel() {
        isCancelled = true
        observer = nil
    }


    private func fileDidChange() {
        loadQueue.async { [weak self] in
            guard let self = self else { return }
            self.generation += 1
            self.attemptLoad(generation: self.generation, deadline: Date().addingTimeInterval(self.retryDuration))
        }
    }


    private func attemptLoad(generation: Int, deadline: Date) {
        // A newer change replaces this attempt
        guard generation == self.generation else { return }

        guard let loaded = PDFLoader.loadCompleteDocument(at: url) else {
            // Not (yet) a valid PDF: keep the old document and look again shortly
            guard Date() < deadline else { return }
            loadQueue.asyncAfter(deadline: .now() + retryInterval) { [weak self] in
                self?.attemptLoad(generation: generation, deadline: deadline)
            }
            return
        }

        // Rebuilt, but with the same content
        guard loaded.data != shownData else { return }
        shownData = loaded.data

        // Loads are serial, so deliveries arrive in order and the newest one is applied last
        let document = loaded.document
        callbackQueue.async { [weak self] in
            guard let self = self, !self.isCancelled else { return }
            self.onReload(document)
        }
    }

}
