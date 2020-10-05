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
    
    private static var didSaveNotesCompletions = [(CompletionStatus) -> ()]()
    
    /** Returns the number of pages in the current document */
    public static var pageCount: Int {
        return document?.pageCount ?? 0
    }
    
    private static var documentObserver: FileObserver?
    
    
    
    // MARK: - Setters
    
    /** Sends a notification, that the document was changed. */
    public static func setDocument(_ document: PDFDocument, sender: Any) {
        self.document = document
        NotificationCenter.default.post(name: .didOpenDocument, object: sender)
        
        // Track document changes and update if needed
        guard let documentURL = document.documentURL else { return }
        documentObserver = FileObserver.init(URL: documentURL) {
            DispatchQueue.main.async {
                reloadDocument()
            }
        }
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
    
    
    /** Unsubscribes a target from all notifications sent by `DocumentController`. */
    public static func unsubscribe(target: Any) {
        NotificationCenter.default.removeObserver(target, name: .didOpenDocument, object: nil)
        NotificationCenter.default.removeObserver(target, name: .didCreateNewNotesDocument, object: nil)
        NotificationCenter.default.removeObserver(target, name: .requestSaveNotes, object: nil)
        NotificationCenter.default.removeObserver(target, name: .requestOpenNotes, object: nil)
        NotificationCenter.default.removeObserver(target, name: .didSaveNotes, object: nil)
        NotificationCenter.default.removeObserver(target, name: .didEditNotes, object: nil)
        NotificationCenter.default.removeObserver(target, name: .didOpenNotes, object: nil)
    }
    
    
    
    
    // MARK: Helpers
    
    private static func reloadDocument() {
        guard let documentURL = document?.documentURL else { return }
        guard let pdfDocument = PDFDocument(url: documentURL) else { return }
        setDocument(pdfDocument, sender: self)
        PageController.selectPage(at: PageController.currentPage, sender: self)
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
}
