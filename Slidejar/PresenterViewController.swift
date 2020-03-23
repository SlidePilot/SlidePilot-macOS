//
//  PresenterViewController.swift
//  Slidejar
//
//  Created by Pascal Braband on 23.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class PresenterViewController: NSViewController {
    
    @IBOutlet weak var clockLabel: ClockLabel!
    @IBOutlet weak var timingControl: TimingControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timingControl.start()
    }
    
    
    override func viewWillAppear() {
        self.view.window?.delegate = self
    }
}




extension PresenterViewController: NSWindowDelegate {
    func windowDidResize(_ notification: Notification) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "WindowDidResize"), object: nil)
    }
}
