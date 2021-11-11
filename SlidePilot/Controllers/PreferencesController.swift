//
//  PreferencesController.swift
//  SlidePilot
//
//  Created by Pascal Braband on 23.06.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class PreferencesController {
    
    private enum Keys: String {
        case isSleepDisabled = "isSleepDisabled"
        case layoutPadding = "layoutPadding"
    }
    
    
    /**
     This method applies the default preferences (from `UserDefaults`). This method should be called on app start.
     */
    public static func applyDefaults() {
        applySleep()
    }
    
    
    
    // MARK: - Sleeping
    
    private static let awakeManager = AwakeManager()
    public static var isSleepDisabled: Bool {
        return UserDefaults.standard.bool(forKey: Keys.isSleepDisabled.rawValue)
    }
    
    
    /**
     Applies the default value for disabling sleep.
     */
    public static func applySleep() {
        if isSleepDisabled {
            disableSleep()
        } else {
            enableSleep()
        }
    }
    
    
    /**
     Prevents the Mac from falling asleep.
     */
    public static func disableSleep() {
        guard awakeManager.disableScreenSleep() ?? false else { return }
        UserDefaults.standard.set(true, forKey: Keys.isSleepDisabled.rawValue)
    }
    
    
    /**
     Allows the Mac to fall asleep.
     */
    public static func enableSleep() {
        guard awakeManager.enableScreenSleep() else { return }
        UserDefaults.standard.set(false, forKey: Keys.isSleepDisabled.rawValue)
    }
    
    
    
    
    // MARK: - Layout
    
    enum LayoutPadding: Int, Codable {
        case none = 0
        case small = 15
        case normal = 30
    }
    
    public static var layoutPadding: LayoutPadding {
        if let userDefaultsPadding = UserDefaults.standard.object(forKey: Keys.layoutPadding.rawValue) as? Int,
           let layoutPadding = LayoutPadding(rawValue: userDefaultsPadding) {
            return layoutPadding
        } else {
            return .normal
        }
    }
    
    
    
    
    // MARK: - Subscribe
    
    /** Changes the layout padding and sends notification, that this property changed. */
    public static func setLayoutPadding(_ padding: LayoutPadding, sender: Any) {
        UserDefaults.standard.set(padding.rawValue, forKey: Keys.layoutPadding.rawValue)
        NotificationCenter.default.post(name: .didChangeLayoutPadding, object: sender)
    }
    
    /** Subscribes a target to all `.didChangeDisplayWhiteCurtain` notifications sent by `DisplayController`. */
    public static func subscribeLayoutPadding(target: Any, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: .didChangeLayoutPadding, object: nil)
    }
    
    
    
    
    // MARK: - Unsubscribe
    
    /** Unsubscribes a target from all notifications sent by `PreferencesController`. */
    public static func unsubscribe(target: Any) {
        NotificationCenter.default.removeObserver(target, name: .didChangeLayoutPadding, object: nil)
    }

}




extension Notification.Name {
    static let didChangeLayoutPadding = Notification.Name("didChangeLayoutPadding")
}
