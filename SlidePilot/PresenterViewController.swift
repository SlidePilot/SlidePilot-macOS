//
//  PresenterViewController.swift
//  SlidePilot
//
//  Created by Pascal Braband on 23.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa
import PDFKit




protocol MousePointerDelegate {
    func showPointer()
    func hidePointer()
    
    /** `position` is the relative position of the pointer in the displayed image. */
    func pointerMoved(to position: NSPoint)
    
    var isPointerShown: Bool { get }
}




class PresenterViewController: NSViewController {
    
    var pointerDelegate: MousePointerDelegate?
    
    @IBOutlet weak var clockLabel: ClockLabel!
    @IBOutlet weak var timingControl: TimingControl!
    @IBOutlet weak var slideArrangement: SlideArrangementView!
    
    var navigation: ThumbnailNavigation?
    var navigationLeft: NSLayoutConstraint?
    let navigationWidth: CGFloat = 180.0
    
    
    var presentationMenu: NSMenu? {
        NSApp.menu?.items.first(where: { $0.identifier == NSUserInterfaceItemIdentifier(rawValue: "PresentationMenu") })?.submenu
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
        
        // Select notes position none by default
        if let notesPositionItem = presentationMenu?.items.first(where: { $0.identifier == NSUserInterfaceItemIdentifier("NotesPosition")} ),
            let notesPositionNoneItem = notesPositionItem.submenu?.items.first(where: { $0.identifier == NSUserInterfaceItemIdentifier("NotesPositionNone")}),
            let notesPositionNoneAction = notesPositionNoneItem.action {
            NSApp.sendAction(notesPositionNoneAction, to: notesPositionNoneItem.target, from: notesPositionNoneItem)
        }
    }
    
    
    override func viewDidAppear() {
        // Don't have any controls active when view appears
        endEditing()
        
        let alreadyDisplayedKey = "AlreadyDisplayedDonationAlert"
        let alreadyDisplayedDonation = UserDefaults.standard.bool(forKey: alreadyDisplayedKey)
        
        // Only show donation alert after thrid app start and if not already displayed
        if AppStartTracker.count >= 5, !alreadyDisplayedDonation {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                UserDefaults.standard.set(true, forKey: alreadyDisplayedKey)
                
                let alert = NSAlert()
                alert.messageText = NSLocalizedString("Donation Alert Text", comment: "Title for the donation alert.")
                alert.informativeText = NSLocalizedString("Donation Alert Message", comment: "Message for the donation alert.")
                alert.alertStyle = NSAlert.Style.informational
                alert.addButton(withTitle: NSLocalizedString("Donate Button", comment: "Title for the donate button in the donation alert."))
                alert.addButton(withTitle: NSLocalizedString("Donate Cancel Button", comment: "Title for the cancel button in the donation alert."))
                let res = alert.runModal()
                if res == .alertFirstButtonReturn {
                    NSWorkspace.shared.open(URL(string: "https://slidepilotapp.com/donate.html")!)
                }
            }
        }
    }
    
    
    
    
    // MARK: - Menu Actions
    
    var isNavigationShown = false
    
    @IBAction func showNavigator(_ sender: NSMenuItem) {
        if isNavigationShown {
            hideNavigation(animated: true)
        } else {
            showNavigation()
        }
        
        sender.state = isNavigationShown ? .on : .off
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
        
        // Select notes position right by default when displaying notes
        // Only if notes are displayed right now and current note position is none
        if slideArrangement.displayNotes, slideArrangement.notesPosition == .none,
            let notesPositionItem = sender.menu?.items.first(where: { $0.identifier == NSUserInterfaceItemIdentifier("NotesPosition")} ),
            let notesPositionRightItem = notesPositionItem.submenu?.items.first(where: { $0.identifier == NSUserInterfaceItemIdentifier("NotesPositionRight")}),
            let notesPositionRightAction = notesPositionRightItem.action {
            NSApp.sendAction(notesPositionRightAction, to: notesPositionRightItem.target, from: notesPositionRightItem)
        }
        
        // Enable/Disable selecting notes position none
        if let notesPositionItem = sender.menu?.items.first(where: { $0.identifier == NSUserInterfaceItemIdentifier("NotesPosition")} ),
            let notesPositionNoneItem = notesPositionItem.submenu?.items.first(where: { $0.identifier == NSUserInterfaceItemIdentifier("NotesPositionNone")}) {
            notesPositionNoneItem.isEnabled = !slideArrangement.displayNotes
        }
    }
    
    
    var isShowCursorActive: Bool = false
    
    @IBAction func showCursor(_ sender: NSMenuItem) {
        // Set delegate to receive mouse events
        slideArrangement.delegate = self
        
        // Start tracking by setting initial tracking area
        slideArrangement.currentSlideView?.addTrackingAreaForSlide()
        
        guard pointerDelegate != nil else { return }
        if isShowCursorActive {
            pointerDelegate!.hidePointer()
            isShowCursorActive = false
        } else {
            isShowCursorActive = true
        }
        
        sender.state = isShowCursorActive ? .on : .off
    }
    
    
    
    
    // MARK: - Navigation
    
    func setupNavigation() {
        guard navigation == nil else { return }
        navigation = ThumbnailNavigation(frame: .zero)
        navigation!.translatesAutoresizingMaskIntoConstraints = false
        
        navigation!.delegate = slideArrangement
        slideArrangement.slideDelegate = navigation!
        
        self.view.addSubview(navigation!)
        navigationLeft = NSLayoutConstraint(item: navigation!, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: -navigationWidth)
        self.view.addConstraints([navigationLeft!,
                             NSLayoutConstraint(item: navigation!, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0.0),
                             NSLayoutConstraint(item: navigation!, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0.0),
                             NSLayoutConstraint(item: navigation!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: navigationWidth)])
        
        // Set inital configuration
        navigation?.document = slideArrangement.pdfDocument
        navigation?.displayMode = slideArrangement.notesPosition.displayModeForPresentation()
    }
    
    
    /** Shows the ThumbnailNavigation view. */
    func showNavigation() {
        setupNavigation()
        guard navigation != nil, navigationLeft != nil else { return }
        
        if let currentPage = slideArrangement.currentSlideView?.page?.currentPage {
            DispatchQueue.main.async {
                self.navigation?.selectThumbnail(at: currentPage, scrollVisible: true)
            }
        }
        navigationLeft!.constant = 0.0
        self.view.updateConstraints()
        navigation?.searchField.becomeFirstResponder()
        
        isNavigationShown = true
    }
    
    
    /** Hides the ThumbnailNavigation view. */
    func hideNavigation(animated: Bool) {
        guard navigation != nil, navigationLeft != nil else { return }
        navigationLeft!.constant = -navigationWidth
        endEditing()
        
        if animated {
            NSAnimationContext.runAnimationGroup({ (context) in
                context.duration = 0.25
                context.allowsImplicitAnimation = true
                context.timingFunction = CAMediaTimingFunction(name: .easeIn)
                self.view.updateConstraints()
                self.view.layoutSubtreeIfNeeded()
            }) {
                self.navigation?.removeFromSuperview()
                self.navigation = nil
            }
        } else {
            self.view.updateConstraints()
        }
        
        isNavigationShown = false
    }
    
    
    override func cancelOperation(_ sender: Any?) {
        hideNavigation(animated: true)
    }
    
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        endEditing()
    }
    
    
    /** Ends editing for all NSControls */
    func endEditing() {
        self.view.window?.makeFirstResponder(nil)
    }
}




extension PresenterViewController: SlideTrackingDelegate {
    
    func mouseMoved(to position: NSPoint, in sender: PDFPageView?) {
        guard isShowCursorActive else { return }
        guard let page = sender else { return }
        
        // Calculate relative position by setting width to 100
        let relativeInImage = calculateRelativePosition(for: position, in: page)
        
        // Hide Pointer if at edge of view
        if relativeInImage.x < 0.01 || relativeInImage.x > 0.99 || relativeInImage.y < 0.01 || relativeInImage.y > 0.99 {
            pointerDelegate?.hidePointer()
        } else {
            pointerDelegate?.showPointer()
            pointerDelegate?.pointerMoved(to: relativeInImage)
        }
    }
    
    
    func calculateRelativePosition(for position: NSPoint, in view: NSImageView) -> NSPoint {
        // Calculate position in image view
        let imageViewOrigin = view.convert(view.frame.origin, to: self.view)
        let imageFrame = view.imageRect()
        let imageOrigin = imageFrame.origin
        
        let positionInImage = NSPoint(x: position.x - imageViewOrigin.x - imageOrigin.x,
                                      y: position.y - imageViewOrigin.y - imageOrigin.y)
        
        // Calculate relative position by setting width to 100
        let relativeInImage = NSPoint(x: positionInImage.x / imageFrame.width,
                                      y: positionInImage.y / imageFrame.height)
        
        return relativeInImage
    }
}
