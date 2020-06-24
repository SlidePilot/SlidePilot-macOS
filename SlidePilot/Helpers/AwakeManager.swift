//
//  AwakeManager.swift
//  SlidePilot
//
//  Created by Pascal Braband on 23.06.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import IOKit.pwr_mgt

class AwakeManager {
    
    var noSleepAssertionID: IOPMAssertionID = 0
    var noSleepReturn: IOReturn? // Could probably be replaced by a boolean value, for example 'isBlockingSleep', just make sure 'IOPMAssertionRelease' doesn't get called, if 'IOPMAssertionCreateWithName' failed.

    public func disableScreenSleep(reason: String = "Keep Mac awake during presentations.") -> Bool? {
        guard noSleepReturn == nil else { return nil }
        noSleepReturn = IOPMAssertionCreateWithName(kIOPMAssertionTypeNoDisplaySleep as CFString,
                                                IOPMAssertionLevel(kIOPMAssertionLevelOn),
                                                reason as CFString,
                                                &noSleepAssertionID)
        return noSleepReturn == kIOReturnSuccess
    }

    public func enableScreenSleep() -> Bool {
        if noSleepReturn != nil {
            _ = IOPMAssertionRelease(noSleepAssertionID) == kIOReturnSuccess
            noSleepReturn = nil
            return true
        }
        return false
    }

}
