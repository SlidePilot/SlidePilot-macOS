//
//  RemoteVerificationViewController.swift
//  SlidePilot
//
//  Created by Pascal Braband on 08.10.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class RemoteVerificationViewController: NSViewController {

    @IBOutlet weak var infoLabel: NSTextField!
    @IBOutlet weak var descriptionLabel: NSTextField!
    @IBOutlet weak var codeLabel: NSTextField!


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    
    @IBAction func confirm(_ sender: Any) {
        self.dismiss(self)
    }
    
    
    @IBAction func cancel(_ sender: Any) {
        
    }
    
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        print("segue")
    }
}
