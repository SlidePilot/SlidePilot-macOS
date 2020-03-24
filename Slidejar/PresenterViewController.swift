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
    
    var fileMenu: NSMenu? {
        NSApp.menu?.items.first(where: { $0.identifier == NSUserInterfaceItemIdentifier(rawValue: "FileMenu") })?.submenu
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        if let notesPositionItem = presentationMenu?.items.first(where: { $0.identifier == NSUserInterfaceItemIdentifier("NotesPosition")} ) {
            if let notesPositionNoneItem = notesPositionItem.submenu?.items.first(where: { $0.identifier == NSUserInterfaceItemIdentifier("NotesPositionNone")}) {
                selectNotesPositionNone(notesPositionNoneItem)
            }
        }
        
    }
    
    
    override func viewDidAppear() {
        DispatchQueue.main.async {
            if let openItem = self.fileMenu?.items.first(where: { $0.identifier == NSUserInterfaceItemIdentifier("Open") }) {
                self.openDocument(openItem)
            }
        }
    }
    
    
    func openFile(url: URL) {
        NSDocumentController.shared.noteNewRecentDocumentURL(url)
        guard let pdfDocument = PDFDocument(url: url) else { return }
        slideArrangement.pdfDocument = pdfDocument
    }
    
    
    // MARK: - Menu Actions
    
    @IBAction func openDocument(_ sender: NSMenuItem) {
        let dialog = NSOpenPanel();

        dialog.title = NSLocalizedString("Choose File", comment: "Title for open file panel.");
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = false
        dialog.canCreateDirectories = false
        dialog.allowsMultipleSelection = false

        if (dialog.runModal() == .OK) {
            if let result = dialog.url {
                openFile(url: result)
            }
        }
    }
    
    
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
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("Enter Timer Interval", comment: "Alert message asking for timer interval.")
        alert.informativeText = NSLocalizedString("Enter Timer Interval Text", comment: "Alert text asking for timer interval.")
        alert.alertStyle = NSAlert.Style.informational
        alert.addButton(withTitle: NSLocalizedString("OK", comment: "Title for ok button."))
        alert.addButton(withTitle: NSLocalizedString("Cancel", comment: "Title for cancel button."))
        
        let timePicker = NSDatePicker(frame: NSRect(x: 0.0, y: 0.0, width: 200.0, height: 24.0))
        timePicker.datePickerStyle = .textFieldAndStepper
        timePicker.datePickerElements = .hourMinuteSecond
        timePicker.setTime(timingControl.timerInterval)
        alert.accessoryView = timePicker
        
        if let window = self.view.window {
            alert.beginSheetModal(for: window) { (response) in
                self.timingControl.setTimer(timePicker.time)
            }
        }
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
        
        // Select notes position right by default
        if let notesPositionItem = sender.menu?.items.first(where: { $0.identifier == NSUserInterfaceItemIdentifier("NotesPosition")} ) {
            // Only if notes are displayed right now and current note position is none
            if slideArrangement.displayNotes, slideArrangement.notesPosition == .none {
                if let notesPositionRightItem = notesPositionItem.submenu?.items.first(where: { $0.identifier == NSUserInterfaceItemIdentifier("NotesPositionRight")}) {
                    selectNotesPositionRight(notesPositionRightItem)
                }
            }
        }
    }
    
    
    @IBAction func selectNotesPositionNone(_ sender: NSMenuItem) {
        // Turn off all menu items in same menu
        sender.menu?.items.forEach({ $0.state = .off })
        sender.state = .on
        
        slideArrangement.notesPosition = .none
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
    
    
    @IBAction func showMouse(_ sender: NSMenuItem) {
        guard let slideView = slideArrangement.currentSlideView else { return }
        //let r = self.view.addTrackingRect(currentSlideView.bounds, owner: self, userData: nil, assumeInside: false)
        self.view.addTrackingArea(NSTrackingArea(rect: slideView.frame, options: [.mouseEnteredAndExited, .mouseMoved, .activeInKeyWindow], owner: self, userInfo: nil))
    }
    
    
    override func mouseMoved(with event: NSEvent) {
//        NSPoint eyeCenter = [self convertPoint:[theEvent locationInWindow] fromView:nil];
//        eyeBox = NSMakeRect((eyeCenter.x-10.0), (eyeCenter.y-10.0), 20.0, 20.0);
//        [self setNeedsDisplayInRect:eyeBox];
//        [self displayIfNeeded];
        
        print("Mouse Loc: \(event.locationInWindow)")
        guard let currentSlideView = slideArrangement.currentSlideView else { return }
        let mouseCenter = currentSlideView.convert(event.locationInWindow, to: currentSlideView)
        print(mouseCenter)
    }
}
