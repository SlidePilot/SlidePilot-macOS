//
//  SplitView.swift
//  SlidePilot
//
//  Created by Pascal Braband on 29.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class SplitView: NSSplitView {

    override var dividerColor: NSColor {
        return (divCol == nil) ? super.dividerColor : divCol!
    }
    
    var divCol: NSColor?
    func setDividerColor(_ color: NSColor) {
        divCol = color
    }
    
}
