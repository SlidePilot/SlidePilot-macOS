//
//  TimeController.swift
//  SlidePilot
//
//  Created by Pascal Braband on 05.05.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class TimeController {
    
    enum TimeMode {
        case stopwatch, timer
    }
    
    public private(set) static var timeMode: TimeMode = .stopwatch
    public private(set) static var isRunning: Bool = false
    
    
    /** Sends a notification, that the time mode was changed */
    public static func setTimeMode(mode: TimeMode, sender: Any?) {
        self.timeMode = mode
        NotificationCenter.default.post(name: .didChangeTimeMode, object: sender)
    }
    
    
    /** Sends a notification, that the `isRunning` property was changed. */
    public static func setIsRunning(_ isRunning: Bool, sender: Any) {
        self.isRunning = isRunning
        NotificationCenter.default.post(name: .didChangeTimeIsRunning, object: sender)
    }
    
    
    /** Changes `isRunning` to the opposite and sends notification, that this property changed. */
    public static func switchIsRunning(sender: Any) {
        setIsRunning(!isRunning, sender: sender)
    }
    
    
    /** Sends a notification, that the time was reset. */
    public static func resetTime(sender: Any) {
        NotificationCenter.default.post(name: .didResetTime, object: sender)
        setIsRunning(false, sender: sender)
    }
    
    
    /** Subscribes a target to all `.didChangeTimeMode` notifications sent by `TimeController`. */
    public static func subscribeTimeMode(target: Any, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: .didChangeTimeMode, object: nil)
    }
    
    
    /** Subscribes a target to all `.didChangeTimeIsRunning` notifications sent by `TimeController`. */
    public static func subscribeIsRunning(target: Any, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: .didChangeTimeIsRunning, object: nil)
    }
    
    
    /** Subscribes a target to all `.didResetTime` notifications sent by `TimeController`. */
    public static func subscribeReset(target: Any, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: .didResetTime, object: nil)
    }
    
    
    /** Unsubscribes a target from all notifications sent by `TimeController`. */
    public static func unsubscribe(target: Any) {
        NotificationCenter.default.removeObserver(target, name: .didChangeTimeMode, object: nil)
        NotificationCenter.default.removeObserver(target, name: .didChangeTimeIsRunning, object: nil)
        NotificationCenter.default.removeObserver(target, name: .didResetTime, object: nil)
    }
}




extension Notification.Name {
    static let didChangeTimeMode = Notification.Name("didChangeTimeMode")
    static let didChangeTimeIsRunning = Notification.Name("didChangeStartStopTime")
    static let didResetTime = Notification.Name("didResetTime")
}
