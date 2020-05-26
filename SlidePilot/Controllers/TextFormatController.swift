//
//  TextFormatController.swift
//  SlidePilot
//
//  Created by Pascal Braband on 26.05.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class TextFormatController: NSObject {
    
    
    // MARK: - Senders
    
    /** Sends a notification, that the font size should be increased. */
    public static func increaseFontSize(sender: Any?) {
        NotificationCenter.default.post(name: .increaseFontSize, object: sender)
    }
    
    
    /** Sends a notification, that the font size should be decreased. */
    public static func decreaseFontSize(sender: Any?) {
        NotificationCenter.default.post(name: .decreaseFontSize, object: sender)
    }
    
    
    
    // MARK: - Subscribe
    
    /** Subscribes a target to all `.increaseFontSize` notifications sent by `TextFormatController`. */
    public static func subscribeIncreaseFontSize(target: Any, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: .increaseFontSize, object: nil)
    }
    
    
    /** Subscribes a target to all `.decreaseFontSize` notifications sent by `TextFormatController`. */
    public static func subscribeDecreaseFontSize(target: Any, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: .decreaseFontSize, object: nil)
    }
    
    
    /** Unsubscribes a target from all notifications sent by `PageController`. */
    public static func unsubscribe(target: Any) {
        NotificationCenter.default.removeObserver(target, name: .increaseFontSize, object: nil)
        NotificationCenter.default.removeObserver(target, name: .decreaseFontSize, object: nil)
    }
}




extension Notification.Name {
    static let increaseFontSize = Notification.Name("increaseFontSize")
    static let decreaseFontSize = Notification.Name("decreaseFontSize")
}
