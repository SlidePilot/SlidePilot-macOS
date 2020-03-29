//
//  TimingControl.swift
//  SlidePilot
//
//  Created by Pascal Braband on 23.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class TimingControl: NSTextField {
    
    
    // MARK: - UI Properties
    
    var textColorRunning: NSColor = NSColor.white
    var textColorTimeOver: NSColor = NSColor(named: "OverTimeColor")!
    
    
    
    
    // MARK: - Timing Properties
    
    enum Mode {
        case stopwatch, timer
    }
    
    
    var mode: Mode = .stopwatch {
        didSet {
            stop()
            counter = 0
            timerInterval = 0
            updateLabel()
        }
    }
    
    /***/
    private var counter: TimeInterval = 0.0
    
    /***/
    private var timer: Timer? = nil
    
    /***/
    private(set) var isRunning: Bool = false
    
    /***/
    private(set) var timerInterval: TimeInterval = 0.0
    
    
    
    
    // MARK: - Initalizers
    
    init(mode: Mode) {
        super.init(frame: NSRect.zero)
        
        self.mode = mode
        updateLabel()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        updateLabel()
    }
    
    
    
    
    // MARK: - UI Manipulation
    
    /***/
    private func updateLabel() {
        if counter >= 0 {
            self.textColor = textColorRunning
        } else {
            self.textColor = textColorTimeOver
        }
        self.stringValue = counter.format()
    }
    
    
    
    
    // MARK: - Timing Controls
    
    /***/
    func setTimer(_ interval: TimeInterval) {
        if mode == .timer {
            timerInterval = interval
            counter = timerInterval
            updateLabel()
        }
    }
    
    
    /** Toggle to start/stop timer. */
    func startStop() {
        if isRunning {
            stop()
        } else {
            start()
        }
    }
    
    
    /** Starts the stopwatch counting up or the timer counting down, dependent on the chosen `mode`. */
    func start() {
        if !isRunning {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
            RunLoop.main.add(timer!, forMode: RunLoop.Mode.common)
            isRunning = true
        }
    }
    
    
    /** Stops the stopwatch or timer. */
    func stop() {
        if isRunning {
            timer?.invalidate()
            isRunning = false
        }
    }
    
    
    /**
     Resets the control dependent on the chosen `mode`.
     * `.stopwatch`: Resets to 0
     * `.timer`: Resets to last given `timerInterval`
     */
    func reset() {
        stop()
        
        switch mode {
        case .stopwatch:
            counter = 0.0
        case .timer:
            counter = timerInterval
        }
        updateLabel()
    }
    
    
    /***/
    @objc private func updateTime() {
        switch mode {
        case .stopwatch:
            counter += 1
        case .timer:
            counter -= 1
        }
        updateLabel()
    }
    
    
}
