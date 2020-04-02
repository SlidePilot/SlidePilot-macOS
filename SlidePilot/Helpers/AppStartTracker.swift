//
//  AppStartTracker.swift
//  SlidePilot
//
//  Created by Pascal Braband on 02.04.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class AppStartTracker {

    private static let appStartCountKey = "AppStartCount"
    private static let countLimit = 4
    public static private(set) var count = 0
    
    public static func startup() {
        count = UserDefaults.standard.integer(forKey: appStartCountKey)
        if count < countLimit {
            count += 1
            UserDefaults.standard.set(count, forKey: appStartCountKey)
        }
    }
    
}
