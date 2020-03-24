//
//  NSDatePicker+Extension.swift
//  Slidejar
//
//  Created by Pascal Braband on 24.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

extension NSDatePicker {

    /** Returns the `TimeInterval` from midnight to the chosen dates time. */
    var time: TimeInterval {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let hour = calendar.component(.hour, from: self.dateValue)
        let minutes = calendar.component(.minute, from: self.dateValue)
        let seconds = calendar.component(.second, from: self.dateValue)
        
        return TimeInterval(hour * 3600 + minutes * 60 + seconds)
    }
    
    
    /** Sets the `dateValue` of the picker to midnight. */
    func setZeroTime() {
        self.dateValue = ISO8601DateFormatter().date(from: "2020-01-01T00:00:00Z")!
        self.timeZone = TimeZone(secondsFromGMT: 0)
    }
    
    
    func setTime(_ interval: TimeInterval) {
        setZeroTime()
        self.dateValue = self.dateValue + interval
    }
}
