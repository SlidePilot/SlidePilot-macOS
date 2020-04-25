//
//  DisplayController.swift
//  SlidePilot
//
//  Created by Pascal Braband on 25.04.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Foundation

class DisplayController {
    
    enum NotesPosition {
        case none, right, left, bottom, top
        
        func displayModeForNotes() -> PDFPageView.DisplayMode {
            switch self {
            case .none:
                return .full
            case .right:
                return .rightHalf
            case .left:
                return .leftHalf
            case .bottom:
                return .bottomHalf
            case .top:
                return .topHalf
            }
        }
        
        func displayModeForPresentation() -> PDFPageView.DisplayMode {
            switch self {
            case .none:
                return .full
            case .right:
                return .leftHalf
            case .left:
                return .rightHalf
            case .bottom:
                return .topHalf
            case .top:
                return .bottomHalf
            }
        }
    }
    
    public private(set) static var notesPosition: NotesPosition = .none
    public private(set) static var displayNotes: Bool = false
    
    
    /** Sends a notification, that the notes position was changed. */
    public static func setNotesPosition(_ position: NotesPosition, sender: Any) {
        notesPosition = position
        NotificationCenter.default.post(name: .didChangeNotesPosition, object: sender)
    }
    
    
    /** Changes display notes to the opposite and sends notification, that this property changed. */
    public static func switchDisplayNotes(sender: Any) {
        setDisplayNotes(!displayNotes, sender: sender)
    }
    
    
    /** Sends a notification, that the display notes property was changed. */
    public static func setDisplayNotes(_ shouldDisplay: Bool, sender: Any) {
        displayNotes = shouldDisplay
        NotificationCenter.default.post(name: .didChangeDisplayNotes, object: sender)
    }
    
    
    /** Subscribes a target to all `.didChangeNotesPosition` notifications sent by `DisplayController`. */
    public static func subscribeNotesPosition(target: Any, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: .didChangeNotesPosition, object: nil)
    }
    
    
    /** Subscribes a target to all `.didChangeDisplayNotes` notifications sent by `DisplayController`. */
    public static func subscribeDisplayNotes(target: Any, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: .didChangeDisplayNotes, object: nil)
    }
    
    
    /** Unsubscribes a target from all notifications sent by `DisplayController`. */
    public static func unsubscribe(target: Any) {
        NotificationCenter.default.removeObserver(target, name: .didChangeNotesPosition, object: nil)
    }
}




extension Notification.Name {
    static let didChangeNotesPosition = Notification.Name("didChangeNotesPosition")
    static let didChangeDisplayNotes = Notification.Name("didChangeDisplayNotes")
}
