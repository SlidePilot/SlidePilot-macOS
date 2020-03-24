//
//  PresentationViewController.swift
//  Slidejar
//
//  Created by Pascal Braband on 24.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class PresentationViewController: NSViewController {

    @IBOutlet weak var pageView: PDFPageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.black.cgColor
    }
    
}
