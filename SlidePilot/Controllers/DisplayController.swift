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
    
    
    /** Sends a notification, that the notes position was changed. */
    public static func setNotesPosition(_ position: NotesPosition, sender: Any) {
        notesPosition = position
        NotificationCenter.default.post(name: .didChangeNotesPosition, object: sender)
    }
    
    
    /** Subscribes a target to all notifications sent by `DisplayController`. */
    public static func subscribe(target: Any, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: .didChangeNotesPosition, object: nil)
    }
    
    
    /** Unsubscribes a target from all notifications sent by `DisplayController`. */
    public static func unsubscribe(target: Any) {
        NotificationCenter.default.removeObserver(target, name: .didChangeNotesPosition, object: nil)
    }
}




extension Notification.Name {
    static let didChangeNotesPosition = Notification.Name("didChangeNotesPosition")
}
