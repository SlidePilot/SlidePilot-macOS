//
//  TimeView.swift
//  Slidejar
//
//  Created by Pascal Braband on 23.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class TimeView: NSView {
    
    
    enum LayoutType {
        case clockLeft, clockRight, clockSmall
    }
    
    
    var layout: LayoutType = .clockLeft {
        didSet {
            setup()
        }
    }
    
    
    /** Defines the partitioning between left and right time label.
     _Default:_ `0.5`, means both labels are distributed equally */
    var horizontalDistribution: CGFloat = 0.5 {
        didSet {
            setup()
        }
    }
    
    var verticalDistribution: CGFloat = 0.5 {
        didSet {
            setup()
        }
    }
    
    
    var timingControl: TimingControl = TimingControl(mode: .stopwatch)
    var clockLabel: ClockLabel = ClockLabel()
    
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        self.layout = .clockLeft
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.layout = .clockLeft
    }
    
    
    private func setup() {
        // Remove all subviews
        self.subviews.forEach({ $0.removeFromSuperview() })
        
        switch self.layout {
        case .clockLeft:
            setupClockLeft()
        case .clockRight:
            setupClockRight()
        case .clockSmall:
            setupClockSmall()
        }
    }
    
    
    private func setupClockLeft() {
        timingControl.reset()
        
        
    }
    
    
    private func setupClockRight() {
        timingControl.reset()
        
        
    }
    
    
    private func setupClockSmall() {
        timingControl.reset()
        
        
    }
}
