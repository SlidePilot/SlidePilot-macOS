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
    
    
    enum CurtainDisplayMode {
        case black, white, none
    }
    
    
    
    
    // MARK: - Variables (Getters)
    public private(set) static var notesPosition: NotesPosition = .none
    
    public private(set) static var areNotesDisplayed: Bool = false
    public private(set) static var isBlackCurtainDisplayed: Bool = false
    public private(set) static var isWhiteCurtainDisplayed: Bool = false
    public private(set) static var isNavigatorDisplayed: Bool = false
    public private(set) static var isPointerDisplayed: Bool = false
    public private(set) static var isNextSlidePreviewDisplayed: Bool = false
    
    public private(set) static var pointerAppearance: PointerView.PointerType = .cursor
    
    
    
    
    // MARK: - Setters
    
    /** Sends a notification, that the notes position was changed. */
    public static func setNotesPosition(_ position: NotesPosition, sender: Any) {
        notesPosition = position
        NotificationCenter.default.post(name: .didChangeNotesPosition, object: sender)
    }
    
    
    /** Changes display notes to the opposite and sends notification, that this property changed. */
    public static func switchDisplayNotes(sender: Any) {
        setDisplayNotes(!areNotesDisplayed, sender: sender)
    }
    
    
    /** Sends a notification, that the display notes property was changed. */
    public static func setDisplayNotes(_ shouldDisplay: Bool, sender: Any) {
        areNotesDisplayed = shouldDisplay
        NotificationCenter.default.post(name: .didChangeDisplayNotes, object: sender)
    }
    
    
    /** Sends a notification, that the display black curtain property was changed. */
    private static func setDisplayBlackCurtain(_ shouldDisplay: Bool, sender: Any) {
        isBlackCurtainDisplayed = shouldDisplay
        NotificationCenter.default.post(name: .didChangeDisplayBlackCurtain, object: sender)
    }
    
    
    /** Sends a notification, that the display white curtain property was changed. */
    private static func setDisplayWhiteCurtain(_ shouldDisplay: Bool, sender: Any) {
        isWhiteCurtainDisplayed = shouldDisplay
        NotificationCenter.default.post(name: .didChangeDisplayWhiteCurtain, object: sender)
    }
    
    
    /**
     Sends a notification, that the display black/white curtain property was changed.
     
     * Switch on **black** curtain: Switches on **black** and switch off **white** if displayed.
     * Switch on **white** curtain: Switches on **white** and switch off **black** if displayed.
     * Switch to **none** curtain: Switches off both **white** and **black** if displayed.
    */
    public static func setDisplayCurtain(_ displayMode: CurtainDisplayMode, sender: Any) {
        switch displayMode {
        case .black:
            // Turn off white curtain if displayed
            if isWhiteCurtainDisplayed {
                setDisplayWhiteCurtain(false, sender: sender)
            }
            setDisplayBlackCurtain(true, sender: sender)
            
        case .white:
            // Turn off black curtain if display
            if isBlackCurtainDisplayed {
                setDisplayBlackCurtain(false, sender: sender)
            }
            setDisplayWhiteCurtain(true, sender: sender)
        
        case .none:
            // Turn off either curtain
            if isBlackCurtainDisplayed {
                setDisplayBlackCurtain(false, sender: sender)
            }
            if isWhiteCurtainDisplayed {
                setDisplayWhiteCurtain(false, sender: sender)
            }
        }
    }
    
    
    /** Changes display black curtain to the opposite and sends notification, that this property changed. */
    public static func switchDisplayBlackCurtain(sender: Any) {
        if isBlackCurtainDisplayed {
            setDisplayCurtain(.none, sender: sender)
        } else {
            setDisplayCurtain(.black, sender: sender)
        }
    }
    
    
    /** Changes display white curtain to the opposite and sends notification, that this property changed. */
    public static func switchDisplayWhiteCurtain(sender: Any) {
        if isWhiteCurtainDisplayed {
            setDisplayCurtain(.none, sender: sender)
        } else {
            setDisplayCurtain(.white, sender: sender)
        }
    }
    
    
    /** Sends a notification, that the display navigator property was changed. */
    public static func setDisplayNavigator(_ shouldDisplay: Bool, sender: Any) {
        isNavigatorDisplayed = shouldDisplay
        NotificationCenter.default.post(name: .didChangeDisplayNavigator, object: sender)
    }
    
    
    /** Changes display navigator to the opposite and sends notification, that this property changed. */
    public static func switchDisplayNavigator(sender: Any) {
        setDisplayNavigator(!isNavigatorDisplayed, sender: sender)
    }
    
    
    /** Sends a notification, that the preview next slide property was changed. */
    public static func setDisplayNextSlidePreview(_ shouldDisplay: Bool, sender: Any) {
        isNextSlidePreviewDisplayed = shouldDisplay
        NotificationCenter.default.post(name: .didChangeDisplayNextSlidePreview, object: sender)
    }
    
    
    /** Changes preview next slide to the opposite and sends notification, that this property changed. */
    public static func switchDisplayNextSlidePreview(sender: Any) {
        setDisplayNextSlidePreview(!isNextSlidePreviewDisplayed, sender: sender)
    }
    
    
    /** Sends a notification, that the display pointer property was changed. */
    public static func setDisplayPointer(_ shouldDisplay: Bool, sender: Any) {
        isPointerDisplayed = shouldDisplay
        NotificationCenter.default.post(name: .didChangeDisplayPointer, object: sender)
    }
    
    /** Changes display pointer to the opposite and sends notification, that this property changed. */
    public static func switchDisplayPointer(sender: Any) {
        setDisplayPointer(!isPointerDisplayed, sender: sender)
    }
    
    
    /** Sends a notification, that the pointer appearance property was changed. */
    public static func setPointerAppearance(_ type: PointerView.PointerType, sender: Any) {
        pointerAppearance = type
        NotificationCenter.default.post(name: .didChangePointerAppearance, object: sender)
    }
    
    
    
    // MARK: - Subscribe
    
    /** Subscribes a target to all `.didChangeNotesPosition` notifications sent by `DisplayController`. */
    public static func subscribeNotesPosition(target: Any, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: .didChangeNotesPosition, object: nil)
    }
    
    
    /** Subscribes a target to all `.didChangeDisplayNotes` notifications sent by `DisplayController`. */
    public static func subscribeDisplayNotes(target: Any, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: .didChangeDisplayNotes, object: nil)
    }
    
    
    /** Subscribes a target to all `.didChangeDisplayBlackCurtain` notifications sent by `DisplayController`. */
    public static func subscribeDisplayBlackCurtain(target: Any, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: .didChangeDisplayBlackCurtain, object: nil)
    }
    
    
    /** Subscribes a target to all `.didChangeDisplayWhiteCurtain` notifications sent by `DisplayController`. */
    public static func subscribeDisplayWhiteCurtain(target: Any, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: .didChangeDisplayWhiteCurtain, object: nil)
    }
    
    
    /** Subscribes a target to all `.didChangeDisplayNavigator` notifications sent by `DisplayController`. */
    public static func subscribeDisplayNavigator(target: Any, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: .didChangeDisplayNavigator, object: nil)
    }
    
    
    /** Subscribes a target to all `.didChangeDisplayNextSlidePreview` notifications sent by `DisplayController`. */
    public static func subscribePreviewNextSlide(target: Any, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: .didChangeDisplayNextSlidePreview, object: nil)
    }
    
    
    /** Subscribes a target to all `.didChangeDisplayPointer` notifications sent by `DisplayController`. */
    public static func subscribeDisplayPointer(target: Any, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: .didChangeDisplayPointer, object: nil)
    }
    
    
    /** Subscribes a target to all `.didChangePointerAppearance` notifications sent by `DisplayController`. */
    public static func subscribePointerAppearance(target: Any, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: .didChangePointerAppearance, object: nil)
    }
    
    
    
    
    // MARK: - Unsubscribe
    
    /** Unsubscribes a target from all notifications sent by `DisplayController`. */
    public static func unsubscribe(target: Any) {
        NotificationCenter.default.removeObserver(target, name: .didChangeNotesPosition, object: nil)
        NotificationCenter.default.removeObserver(target, name: .didChangeDisplayNotes, object: nil)
        NotificationCenter.default.removeObserver(target, name: .didChangeDisplayBlackCurtain, object: nil)
        NotificationCenter.default.removeObserver(target, name: .didChangeDisplayWhiteCurtain, object: nil)
        NotificationCenter.default.removeObserver(target, name: .didChangeDisplayNavigator, object: nil)
        NotificationCenter.default.removeObserver(target, name: .didChangeDisplayPointer, object: nil)
        NotificationCenter.default.removeObserver(target, name: .didChangePointerAppearance, object: nil)
        NotificationCenter.default.removeObserver(target, name: .didChangeDisplayNextSlidePreview, object: nil)
    }
}




extension Notification.Name {
    static let didChangeNotesPosition = Notification.Name("didChangeNotesPosition")
    static let didChangeDisplayNotes = Notification.Name("didChangeDisplayNotes")
    static let didChangeDisplayBlackCurtain = Notification.Name("didChangeDisplayBlackCurtain")
    static let didChangeDisplayWhiteCurtain = Notification.Name("didChangeDisplayWhiteCurtain")
    static let didChangeDisplayNavigator = Notification.Name("didChangeDisplayNavigator")
    static let didChangeDisplayNextSlidePreview = Notification.Name("didChangeDisplayNextSlidePreview")
    static let didChangeDisplayPointer = Notification.Name("didChangeDisplayPointer")
    static let didChangePointerAppearance = Notification.Name("didChangePointerAppearance")
}
