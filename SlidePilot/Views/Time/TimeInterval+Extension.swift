//
//  TimeInterval+Extension.swift
//  SlidePilot
//
//  Created by Pascal Braband on 23.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

extension TimeInterval {

    func format() -> String {
        if self >= 0 {
            let hours = Int(self) / 3600
            let minutes = Int(self) / 60 % 60
            let seconds = Int(self) % 60
            return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
        } else {
            return "- \(abs(self).format())"
        }
    }
    
}
