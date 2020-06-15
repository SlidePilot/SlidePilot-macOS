//
//  CanvasController.swift
//  SlidePilot
//
//  Created by Pascal Braband on 10.06.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class CanvasController: NSObject {
    
    // TODO: make this a computed property based on the Drawing's background color -> return drawing.backgroundColor == .clear
    public private(set) static var isCanvasBackgroundTransparent: Bool = true
    
    
    // MARK: - Senders
    
    /** Sends a notification, that the canvas was cleared. */
    public static func clearCanvas(sender: Any?) {
        NotificationCenter.default.post(name: .didClearCurrentCanvas, object: sender)
    }
    
    
    /** Sends a notification, that the canvas background color changed. */
    public static func setCanvasBackground(to color: NSColor, sender: Any?) {
        NotificationCenter.default.post(name: .didChangeCanvasBackground, object: sender)
    }
    
    
    /** Sets the canvas background to either transparent or blank. */
    public static func setTransparentCanvasBackground(_ isTransparent: Bool, sender: Any?) {
        isCanvasBackgroundTransparent = isTransparent
        if isCanvasBackgroundTransparent {
            setCanvasBackground(to: .clear, sender: self)
        } else {
            setCanvasBackground(to: .white, sender: self)
        }
    }
    
    
    /** Changes transparent canvas to the opposite and sends notification, that this property changed. */
    public static func switchTransparentCanvas(sender: Any?) {
        setTransparentCanvasBackground(!isCanvasBackgroundTransparent, sender: sender)
    }
    
    
    
    // MARK: - Subscribe
    
    /** Subscribes a target to all `.didClearCurrentCanvas` notifications sent by `CanvasController`. */
    public static func subscribeClearCanvas(target: Any, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: .didClearCurrentCanvas, object: nil)
    }
    
    
    /** Subscribes a target to all `.didChangeCanvasBackground` notifications sent by `CanvasController`. */
    public static func subscribeCanvasBackgroundChanged(target: Any, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: .didChangeCanvasBackground, object: nil)
    }
    
    
    /** Unsubscribes a target from all notifications sent by `PageController`. */
    public static func unsubscribe(target: Any) {
        NotificationCenter.default.removeObserver(target, name: .didClearCurrentCanvas, object: nil)
        NotificationCenter.default.removeObserver(target, name: .didChangeCanvasBackground, object: nil)
    }
}




extension Notification.Name {
    static let didClearCurrentCanvas = Notification.Name("didClearCurrentCanvas")
    static let didChangeCanvasBackground = Notification.Name("didChangeCanvasBackground")
}
