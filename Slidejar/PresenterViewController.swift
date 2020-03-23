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
    
    var presentationMenu: NSMenu? {
        NSApp.menu?.items.first(where: { $0.identifier == NSUserInterfaceItemIdentifier(rawValue: "PresentationMenu") })?.submenu
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let path = Bundle.main.path(forResource: "presentation-notes", ofType: "pdf") else { return }
        let url = URL(fileURLWithPath: path)
        guard let pdfDocument = PDFDocument(url: url) else { return }
        slideArrangement.pdfDocument = pdfDocument
        
        // Setup default configuration
        
        // Setup timingControl
        if let timeModeItem = presentationMenu?.items.first(where: { $0.identifier == NSUserInterfaceItemIdentifier(rawValue: "TimeMode") }) {
            if let stopwatchModeItem = timeModeItem.submenu?.items.first(where: { $0.identifier == NSUserInterfaceItemIdentifier(rawValue: "ModeStopwatch") }) {
                selectModeStopwatch(stopwatchModeItem)
            }
        }
        
        // Setup notes
        if let showNotesItem = presentationMenu?.items.first(where: { $0.identifier == NSUserInterfaceItemIdentifier(rawValue: "ShowNotes") }) {
            displayNotes(false, sender: showNotesItem)
        }
    }
    
    
    // MARK: - Menu Actions
    
    @IBAction func previousSlide(_ sender: NSMenuItem) {
        slideArrangement.previousSlide()
    }
    
    
    @IBAction func nextSlide(_ sender: NSMenuItem) {
        slideArrangement.nextSlide()
    }
    
    
    @IBAction func selectModeStopwatch(_ sender: NSMenuItem) {
        // Turn off all menu items in same menu
        sender.menu?.items.forEach({ $0.state = .off })
        sender.state = .on
        timingControl.mode = .stopwatch
        
        // Disable "Set Timer" menu item
        if let setTimerMenuItem = sender.menu?.supermenu?.items.first(where: { $0.identifier == NSUserInterfaceItemIdentifier("SetTimer")} ) {
            setTimerMenuItem.isEnabled = false
        }
    }
    
    
    @IBAction func selectModeTimer(_ sender: NSMenuItem) {
        // Turn off all menu items in same menu
        sender.menu?.items.forEach({ $0.state = .off })
        sender.state = .on
        timingControl.mode = .timer
        
        // Enable "Set Timer" menu item
        if let setTimerMenuItem = sender.menu?.supermenu?.items.first(where: { $0.identifier == NSUserInterfaceItemIdentifier("SetTimer")} ) {
            setTimerMenuItem.isEnabled = true
        }
    }
    
    
    @IBAction func setTimer(_ sender: NSMenuItem) {
        print("set timer")
    }
    
    
    @IBAction func startStopTime(_ sender: NSMenuItem) {
        timingControl.startStop()
    }
    
    
    @IBAction func resetTime(_ sender: NSMenuItem) {
        timingControl.reset()
    }
    
    
    @IBAction func showNotes(_ sender: NSMenuItem) {
        displayNotes(!slideArrangement.displayNotes, sender: sender)
    }
    
    
    func displayNotes(_ shouldDisplay: Bool, sender: NSMenuItem) {
        slideArrangement.displayNotes = shouldDisplay
        sender.state = slideArrangement.displayNotes ? .on : .off
        
        // Enable/Disable notes position submenu
        if let notesPositionItem = sender.menu?.items.first(where: { $0.identifier == NSUserInterfaceItemIdentifier("NotesPosition")} ) {
            notesPositionItem.isEnabled = slideArrangement.displayNotes
            
            // Select notes position right by default
            if slideArrangement.displayNotes {
                if let notesPositionRightItem = notesPositionItem.submenu?.items.first(where: { $0.identifier == NSUserInterfaceItemIdentifier("NotesPositionRight")}) {
                    selectNotesPositionRight(notesPositionRightItem)
                }
            }
        }
    }
    
    
    @IBAction func selectNotesPositionRight(_ sender: NSMenuItem) {
        // Turn off all menu items in same menu
        sender.menu?.items.forEach({ $0.state = .off })
        sender.state = .on
        
        slideArrangement.notesPosition = .right
    }
    
    
    @IBAction func selectNotesPositionLeft(_ sender: NSMenuItem) {
        // Turn off all menu items in same menu
        sender.menu?.items.forEach({ $0.state = .off })
        sender.state = .on
        
        slideArrangement.notesPosition = .left
    }
    
    
    @IBAction func selectNotesPositionBottom(_ sender: NSMenuItem) {
        // Turn off all menu items in same menu
        sender.menu?.items.forEach({ $0.state = .off })
        sender.state = .on
        
        slideArrangement.notesPosition = .bottom
    }
    
    
    @IBAction func selectNotesPositionTop(_ sender: NSMenuItem) {
        // Turn off all menu items in same menu
        sender.menu?.items.forEach({ $0.state = .off })
        sender.state = .on
        
        slideArrangement.notesPosition = .top
    }
}
