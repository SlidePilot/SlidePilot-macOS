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
    public private(set) static var notesFileURL: URL?
    public private(set) static var hasNotesUnsavedChanges: Bool = false
    
    /** Returns the number of pages in the current document */
    public static var pageCount: Int {
        return document?.pageCount ?? 0
    }
    
    
    
    // MARK: - Setters
    
    /** Sends a notification, that the document was changed. */
    public static func setDocument(_ document: PDFDocument, sender: Any) {
        self.document = document
        NotificationCenter.default.post(name: .didOpenDocument, object: sender)
    }
    
    
    /** Requests to save notes to file. */
    public static func requestSaveNotes(sender: Any) {
        // Only save if there are unsaved changes
        guard hasNotesUnsavedChanges else { return }
        NotificationCenter.default.post(name: .requestSaveNotes, object: sender)
    }
    
    
    /** Sends a notification, that saving the document was saved with success value. */
    private static func didSaveDocument(success: Bool, sender: Any) {
        if success {
            hasNotesUnsavedChanges = false
        }
        NotificationCenter.default.post(name: .didSaveNotes, object: sender, userInfo: ["success": success])
    }
    
    
    /** Sends a notification, that the notes were edited. */
    public static func didEditNotes(sender: Any) {
        hasNotesUnsavedChanges = true
        NotificationCenter.default.post(name: .didEditNotes, object: sender)
    }
    
    
    /** Sends a notification, that a opening notes file was requested. */
    public static func requestOpenNotes(sender: Any) {
        NotificationCenter.default.post(name: .requestOpenNotes, object: sender)
    }
    
    
    /** Sends a notification, that a notes file was opened. */
    public static func didOpenNotes(at url: URL, sender: Any) {
        notesFileURL = url
        NotificationCenter.default.post(name: .didOpenNotes, object: sender)
    }
    
    
    /** Sends a notification, that the notes file should be closed. Requests to save the current notes file beforehand. */
    public static func closeNotesFile(sender: Any) {
        requestSaveNotes(sender: sender)
        NotificationCenter.default.post(name: .closeNotes, object: sender)
    }
    
    
    
    // MARK: - Subscribe
    
    /** Subscribes a target to all `.didOpenDocument` notifications sent by `DocumentController`. */
    public static func subscribeDidOpenDocument(target: Any, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: .didOpenDocument, object: nil)
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
    
    
    /** Subscribes a target to all `.closeNotes` notifications sent by `DocumentController`. */
    public static func subscribeCloseNotes(target: Any, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: .closeNotes, object: nil)
    }
    
    
    /** Unsubscribes a target from all notifications sent by `DocumentController`. */
    public static func unsubscribe(target: Any) {
        NotificationCenter.default.removeObserver(target, name: .didOpenDocument, object: nil)
        NotificationCenter.default.removeObserver(target, name: .requestSaveNotes, object: nil)
        NotificationCenter.default.removeObserver(target, name: .requestOpenNotes, object: nil)
        NotificationCenter.default.removeObserver(target, name: .didSaveNotes, object: nil)
        NotificationCenter.default.removeObserver(target, name: .didEditNotes, object: nil)
        NotificationCenter.default.removeObserver(target, name: .didOpenNotes, object: nil)
        NotificationCenter.default.removeObserver(target, name: .closeNotes, object: nil)
    }
}




extension Notification.Name {
    static let didOpenDocument = Notification.Name("didOpenDocument")
    static let requestSaveNotes = Notification.Name("requestSaveNotes")
    static let requestOpenNotes = Notification.Name("requestOpenNotes")
    static let didSaveNotes = Notification.Name("didSaveNotes")
    static let didEditNotes = Notification.Name("didEditNotes")
    static let didOpenNotes = Notification.Name("didOpenNotes")
    static let closeNotes = Notification.Name("closeNotes")
}
