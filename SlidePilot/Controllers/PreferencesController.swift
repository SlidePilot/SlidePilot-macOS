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

}
