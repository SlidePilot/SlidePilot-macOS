//
//  DisturbManager.swift
//  SlidePilot
//
//  Created by Pascal Braband on 24.06.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class DisturbManager: NSObject {
    
    private let notificationCenterDefaults = UserDefaults(suiteName: "com.apple.notificationcenterui")
    
    private enum Keys: String {
        case doNotDisturb = "doNotDisturb"
        case dndStart = "dndStart"
        case dndEnd = "dndEnd"
    }
    
    /** Returns if do not disturb is activated. */
    var isDoNotDisturbActivated: Bool {
        return notificationCenterDefaults?.bool(forKey: Keys.doNotDisturb.rawValue) ?? false
    }
    
    /** Returns the start time of do not disturb. */
    var dndStart: Double {
        return notificationCenterDefaults?.double(forKey: Keys.dndStart.rawValue) ?? 0.0
    }
    
    /** Returns the end time of do not disturb. */
    var dndEnd: Double {
        return notificationCenterDefaults?.double(forKey: Keys.dndEnd.rawValue) ?? 0.0
    }
    
    /** Represents a do not disturb configuration. */
    struct Configuration {
        var isDoNotDisturbAcitvated: Bool
        var dndStart: CGFloat?
        var dndEnd: CGFloat?
    }
    
    /** The do not disturb configuration, before anything has been changed/before initializing*/
    private var initialConfiguration: Configuration!
    
    private let enableConfiguration = Configuration(isDoNotDisturbAcitvated: true, dndStart: 0, dndEnd: 1440)
    private let disableConfiguration = Configuration(isDoNotDisturbAcitvated: false, dndStart: nil, dndEnd: nil)
    
    override init() {
        super.init()
        
        // Get current configuration and save
        initialConfiguration = Configuration(
            isDoNotDisturbAcitvated: isDoNotDisturbActivated,
            dndStart: CGFloat(dndStart),
            dndEnd: CGFloat(dndEnd))
    }
    
    
    /** Applies a given `Configuration` to the `UserDefaults` for do not disturb. */
    func apply(configuration: Configuration) {
//        notificationCenterDefaults?.set(configuration.isDoNotDisturbAcitvated, forKey: Keys.doNotDisturb.rawValue)
//        notificationCenterDefaults?.set(configuration.dndStart, forKey: Keys.dndStart.rawValue)
//        notificationCenterDefaults?.set(configuration.dndEnd, forKey: Keys.dndEnd.rawValue)
//        notificationCenterDefaults?.synchronize()
        
        var dndStart: CFPropertyList? = nil
        if let configDdnStart = configuration.dndStart {
            dndStart = configDdnStart as CFPropertyList
        }
        
        var dndEnd: CFPropertyList? = nil
        if let configDdnEnd = configuration.dndEnd {
            dndEnd = configDdnEnd as CFPropertyList
        }
        
        CFPreferencesSetValue(Keys.doNotDisturb.rawValue as CFString, configuration.isDoNotDisturbAcitvated as CFPropertyList, "com.apple.notificationcenterui" as CFString, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost)
        CFPreferencesSetValue(Keys.dndStart.rawValue as CFString, dndStart, "com.apple.notificationcenterui" as CFString, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost)
        CFPreferencesSetValue(Keys.dndEnd.rawValue as CFString, dndEnd, "com.apple.notificationcenterui" as CFString, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost)
        
        CFPreferencesSynchronize("com.apple.notificationcenterui" as CFString, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost)
        DistributedNotificationCenter.default().postNotificationName(NSNotification.Name(rawValue: "com.apple.notificationcenterui.dndprefs_changed"), object: nil, userInfo: nil, deliverImmediately: true)
    }
    
    
    func enableDND() {
        apply(configuration: enableConfiguration)
        print("enable")
    }
    
    
    func disableDND() {
        apply(configuration: disableConfiguration)
        print("disable")
    }
    
    
    func resetDND() {
        // Revert to configuration before initializing
        apply(configuration: initialConfiguration)
        print("reset to \(initialConfiguration)")
    }
}
