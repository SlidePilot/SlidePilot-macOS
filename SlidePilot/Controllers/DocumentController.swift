//
//  DocumentController.swift
//  SlidePilot
//
//  Created by Pascal Braband on 24.04.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Foundation
import PDFKit

class DocumentController {
    
    public private(set) static var document: PDFDocument?
    public private(set) static var notesDocument: NotesDocument?
    
    /** Dictionary for storing drawing to the associated pages. */
    public private(set) static var drawings = [Int: Drawing]()
    
    private static var didSaveNotesCompletions = [(CompletionStatus) -> ()]()
    
    /** Returns the number of pages in the current document */
    public static var pageCount: Int {
        return document?.pageCount ?? 0
    }
    
    /** The file the current document was opened from. Documents are loaded from memory, so `document.documentURL` is `nil`. */
    public private(set) static var documentURL: URL?
    
    /** Key in the `userInfo` of a `.didOpenDocument` notification, which is `true` when the open document was reloaded from disk. */
    public static let isReloadKey = "isReload"
    
    private static var documentReloader: DocumentReloader?
    
    
    
    // MARK: - Setters
    
    /**
     Sends a notification, that the document was changed.
     
     - parameters:
        - url: The file the document was loaded from. When given, the document is reloaded whenever this file changes.
        - data: The bytes the document was loaded from, used to skip reloads that change nothing.
     */
    public static func setDocument(_ document: PDFDocument, url: URL? = nil, data: Data? = nil, sender: Any) {
        self.document = document
        self.documentURL = url ?? document.documentURL
        PDFMovieFiles.shared.documentURL = documentURL
        NotificationCenter.default.post(name: .didOpenDocument, object: sender)
        
        // Track document changes and update if needed
        documentReloader?.cancel()
        documentReloader = nil
        if let documentURL = documentURL {
            documentReloader = DocumentReloader(url: documentURL, shownData: data) { newDocument in
                reloadDocument(newDocument)
            }
        }
        
        // Reset all drawings
        deleteDrawings(sender: sender)
    }
    
    
    /** Requests to create a new notes document. */
    public static func createNewNotesDocument(sender: Any) {
        guard let document = self.document else { return }
        self.notesDocument = NotesDocument(pageCount: document.pageCount)
        NotificationCenter.default.post(name: .didCreateNewNotesDocument, object: sender)
    }
    
    
    /** Requests to save notes to file. */
    public static func requestSaveNotes(sender: Any, completion: ((CompletionStatus) -> ())? = nil) {
        // Only save if there are unsaved changes
        guard let notesDocument = notesDocument, notesDocument.isDocumentEdited else { return }
        
        // Add completion handler
        if let completion = completion {
            didSaveNotesCompletions.append(completion)
        }
        
        NotificationCenter.default.post(name: .requestSaveNotes, object: sender)
    }
    
    
    /** Sends a notification, that saving the document was saved with status value. */
    public static func didSaveNotes(status: CompletionStatus, sender: Any) {
        performDidSaveNotesCompletions(status)
        NotificationCenter.default.post(name: .didSaveNotes, object: sender, userInfo: ["status": status])
    }
    
    
    private static func performDidSaveNotesCompletions(_ status: CompletionStatus) {
        // Call all completions
        for completion in didSaveNotesCompletions {
            completion(status)
        }
        // Clear completions
        didSaveNotesCompletions.removeAll()
    }
    
    
    /** Sends a notification, that the notes were edited. */
    public static func didEditNotes(sender: Any) {
        NotificationCenter.default.post(name: .didEditNotes, object: sender)
    }
    
    
    /** Sends a notification, that a opening notes file was requested. */
    public static func requestOpenNotes(sender: Any) {
        NotificationCenter.default.post(name: .requestOpenNotes, object: sender)
    }
    
    
    /**
     Sends a notification, that a notes file was opened.
     If `document` is `nil`, then the `.didOpenNotes` notification is send with `false` as success value.
     If `document` is not `nil`, then the `.didOpenNotes` notification is send with `true` as success value.
     */
    public static func didOpenNotes(document: NotesDocument?, sender: Any) {
        if document != nil {
            notesDocument = document
            NotificationCenter.default.post(name: .didOpenNotes, object: sender, userInfo: ["success": true])
        } else {
            NotificationCenter.default.post(name: .didOpenNotes, object: sender, userInfo: ["success": false])
        }
    }
    
    
    /** Saves a drawing for a given page (index). */
    public static func saveDrawing(_ drawing: Drawing, at page: Int, sender: Any) {
        drawings[page] = drawing
        NotificationCenter.default.post(name: .didUpdateDrawings, object: sender)
    }
    
    
    /** Deletes all drawings. */
    public static func deleteDrawings(sender: Any) {
        drawings = [Int: Drawing]()
        NotificationCenter.default.post(name: .didUpdateDrawings, object: sender)
    }
    
    
    
    
    // MARK: - Subscribe
    
    /** Subscribes a target to all `.didOpenDocument` notifications sent by `DocumentController`. */
    public static func subscribeDidOpenDocument(target: Any, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: .didOpenDocument, object: nil)
    }
    
    
    /** Subscribes a target to all `.createNewNotesDocument` notifications sent by `DocumentController`. */
    public static func subscribeNewNotes(target: Any, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: .didCreateNewNotesDocument, object: nil)
    }
    
    
    /** Subscribes a target to all `.requestSaveNotes` notifications sent by `DocumentController`. */
    public static func subscribeRequestSaveNotes(target: Any, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: .requestSaveNotes, object: nil)
    }
    
    
    /** Subscribes a target to all `.didSaveNotes` notifications sent by `DocumentController`. */
    public static func subscribeDidSaveNotes(target: Any, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: .didSaveNotes, object: nil)
    }
    
    
    /** Subscribes a target to all `.didEditNotes` notifications sent by `DocumentController`. */
    public static func subscribeDidEditNotes(target: Any, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: .didEditNotes, object: nil)
    }
    
    
    /** Subscribes a target to all `.requestOpenNotes` notifications sent by `DocumentController`. */
    public static func subscribeRequestOpenNotes(target: Any, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: .requestOpenNotes, object: nil)
    }
    
    
    /** Subscribes a target to all `.didOpenNotes` notifications sent by `DocumentController`. */
    public static func subscribeDidOpenNotes(target: Any, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: .didOpenNotes, object: nil)
    }
    
    
    /** Subscribes a target to all `.didUpdateDrawings` notifications sent by `DocumentController`. */
    public static func subscribeDidUpdateDrawings(target: Any, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: .didUpdateDrawings, object: nil)
    }
    
    
    /** Unsubscribes a target from all notifications sent by `DocumentController`. */
    public static func unsubscribe(target: Any) {
        NotificationCenter.default.removeObserver(target, name: .didOpenDocument, object: nil)
        NotificationCenter.default.removeObserver(target, name: .didCreateNewNotesDocument, object: nil)
        NotificationCenter.default.removeObserver(target, name: .requestSaveNotes, object: nil)
        NotificationCenter.default.removeObserver(target, name: .requestOpenNotes, object: nil)
        NotificationCenter.default.removeObserver(target, name: .didSaveNotes, object: nil)
        NotificationCenter.default.removeObserver(target, name: .didEditNotes, object: nil)
        NotificationCenter.default.removeObserver(target, name: .didOpenNotes, object: nil)
        NotificationCenter.default.removeObserver(target, name: .didUpdateDrawings, object: nil)
    }
    
    
    
    
    // MARK: Helpers
    
    /**
     Swaps in a new version of the open document, after its file was rebuilt. Unlike opening a
     document, this keeps the current page (clamped if the document got shorter), the notes, the
     drawings (if the page count did not change) and the watcher.
     */
    private static func reloadDocument(_ newDocument: PDFDocument) {
        guard document != nil else { return }
        let pageCountChanged = newDocument.pageCount != pageCount
        
        document = newDocument
        
        // Update notes document to fill (new) empty pages
        notesDocument?.fillContents(to: newDocument.pageCount)
        
        // Drawings belong to page numbers, which are no longer reliable when pages were added or removed
        if pageCountChanged {
            drawings = [Int: Drawing]()
        }
        
        let pageChanged = PageController.clampPages(toPageCount: newDocument.pageCount)
        
        NotificationCenter.default.post(name: .didOpenDocument, object: self, userInfo: [isReloadKey: true])
        if pageCountChanged {
            NotificationCenter.default.post(name: .didUpdateDrawings, object: self)
        }
        if pageChanged {
            PageController.notifyPageChange(sender: self)
        }
    }
}




extension Notification {
    /** `true` for a `.didOpenDocument` notification sent because the open document was reloaded from disk. */
    var isDocumentReload: Bool {
        return userInfo?[DocumentController.isReloadKey] as? Bool ?? false
    }
}




extension Notification.Name {
    static let didOpenDocument = Notification.Name("didOpenDocument")
    static let didCreateNewNotesDocument = Notification.Name("didCreateNewNotesDocument")
    static let requestSaveNotes = Notification.Name("requestSaveNotes")
    static let requestOpenNotes = Notification.Name("requestOpenNotes")
    static let didSaveNotes = Notification.Name("didSaveNotes")
    static let didEditNotes = Notification.Name("didEditNotes")
    static let didOpenNotes = Notification.Name("didOpenNotes")
    static let didUpdateDrawings = Notification.Name("didUpdateDrawings")
}
