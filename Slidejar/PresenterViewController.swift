//
//  PresenterViewController.swift
//  Slidejar
//
//  Created by Pascal Braband on 23.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa
import PDFKit

class PresenterViewController: NSViewController {
    
    @IBOutlet weak var clockLabel: ClockLabel!
    @IBOutlet weak var timingControl: TimingControl!
    @IBOutlet weak var slideArrangement: SlideArrangementView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timingControl.start()
        
        guard let path = Bundle.main.path(forResource: "presentation", ofType: "pdf") else { return }
        let url = URL(fileURLWithPath: path)
        guard let pdfDocument = PDFDocument(url: url) else { return }
        slideArrangement.pdfDocument = pdfDocument
    }
    
    
    // MARK: - Menu Actions
    
    @IBAction func previousSlide(_ sender: Any) {
        slideArrangement.previousSlide()
    }
    
    
    @IBAction func nextSlide(_ sender: Any) {
        slideArrangement.nextSlide()
    }
}
