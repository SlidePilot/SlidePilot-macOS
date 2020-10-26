//
//  RemoteVerificationViewController.swift
//  SlidePilot
//
//  Created by Pascal Braband on 08.10.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class RemoteVerificationViewController: NSViewController {

    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var descriptionLabel: NSTextField!
    @IBOutlet weak var codeLabel: NSTextField!
    
    var code: String = ""
    var deviceName: String = ""
    var completiton: ((Bool) -> ())?


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup labels
        titleLabel.stringValue = String(format: NSLocalizedString("Remote Verification Title", comment: "Title for remote verification."), deviceName)
        descriptionLabel.stringValue = String(format: NSLocalizedString("Remote Verification Message", comment: "Message for remote verification."), deviceName)
        codeLabel.stringValue = code

    }
    
    
    @IBAction func confirm(_ sender: Any) {
        completiton?(true)
        self.dismiss(self)
    }
    
    
    @IBAction func cancel(_ sender: Any) {
        completiton?(false)
        self.dismiss(self)
    }
}
