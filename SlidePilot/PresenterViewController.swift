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
    static let navigationWidth: CGFloat = 180.0
    let navigationWidth: CGFloat = PresenterViewController.navigationWidth
    
    
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
        
        // Subscribe to document changes
        DocumentController.subscribe(target: self, action: #selector(documentDidChange(_:)))
        
        // Subscribe to display changes
        DisplayController.subscribeDisplayNavigator(target: self, action: #selector(displayNavigatorDidChange(_:)))
        DisplayController.subscribeDisplayPointer(target: self, action: #selector(displayPointerDidChange(_:)))
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
    
    
    
    
    // MARK: - Control Handlers
    
    @objc func documentDidChange(_ notification: Notification) {
        hideNavigation(animated: false)
    }
    
    
    @objc func displayNavigatorDidChange(_ notification: Notification) {
        if DisplayController.isNavigatorDisplayed {
            showNavigation()
        } else {
            hideNavigation(animated: true)
        }
    }
    
    
    @objc func displayPointerDidChange(_ notification: Notification) {
        // Set delegate to receive mouse events
        slideArrangement.trackingDelegate = self
        
        // Start tracking by setting initial tracking area
        slideArrangement.currentSlideView?.addTrackingAreaForSlide()
        
        guard pointerDelegate != nil else { return }
        // Hide pointer immediately if pointer should not display
        if !DisplayController.isPointerDisplayed {
            pointerDelegate!.hidePointer()
        }
    }
    
    
    
    
    // MARK: - Menu Actions    
    
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
    
    
    
    
    // MARK: - Navigation
    
    func setupNavigation() {
        guard navigation == nil else { return }
        navigation = ThumbnailNavigation(frame: .zero)
        navigation!.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(navigation!)
        navigationLeft = NSLayoutConstraint(item: navigation!, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: -navigationWidth)
        self.view.addConstraints([navigationLeft!,
                             NSLayoutConstraint(item: navigation!, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0.0),
                             NSLayoutConstraint(item: navigation!, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0.0),
                             NSLayoutConstraint(item: navigation!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: navigationWidth)])
    }
    
    
    /** Shows the ThumbnailNavigation view. */
    func showNavigation() {
        setupNavigation()
        guard navigation != nil, navigationLeft != nil else { return }
        
        DispatchQueue.main.async {
            self.navigation?.selectThumbnail(at: PageController.currentPage, scrollVisible: true)
        }
        navigationLeft!.constant = 0.0
        self.view.updateConstraints()
        navigation?.searchField.becomeFirstResponder()
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
    }
    
    
    override func cancelOperation(_ sender: Any?) {
        DisplayController.setDisplayNavigator(false, sender: self)
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
        guard DisplayController.isPointerDisplayed else { return }
        guard let page = sender else { return }
        
        // Calculate relative position by setting width to 100
        let relativeInImage = calculateRelativePosition(for: position, in: page)
        
        // Hide Pointer if at edge of view
        if relativeInImage.x < 0.0 || relativeInImage.x > 1.0 || relativeInImage.y < 0.0 || relativeInImage.y > 1.0 {
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
