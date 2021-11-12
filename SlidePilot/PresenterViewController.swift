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
    
    @IBOutlet weak var timeView: NSView!
    @IBOutlet weak var clockLabel: ClockLabel!
    @IBOutlet weak var timingControl: TimingControl!
    @IBOutlet weak var slideArrangement: SlideArrangementView!
    
    // Constraints
    var slideArrangementFullTopConst: NSLayoutConstraint!
    @IBOutlet var slideArrangementSharedTopConst: NSLayoutConstraint!
    var timeViewSmallHeightConstraint: NSLayoutConstraint!
    @IBOutlet var timeViewNormalHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var clockLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var timingControlHeight: NSLayoutConstraint!
    @IBOutlet weak var timingControlTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var timingControlBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var clockLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var clockLabelBottomConstraint: NSLayoutConstraint!
    
    
    var navigation: ThumbnailNavigation?
    var navigationLeft: NSLayoutConstraint?
    @IBOutlet weak var timingLeftConst: NSLayoutConstraint!
    @IBOutlet weak var slidesLeftConst: NSLayoutConstraint!
    static let navigationWidth: CGFloat = 180.0
    let navigationWidth: CGFloat = PresenterViewController.navigationWidth
    
    var drawingToolbar: DrawingToolbar?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup default configuration
        
        // Subscribe to document changes
        DocumentController.subscribeDidOpenDocument(target: self, action: #selector(documentDidChange(_:)))
        DocumentController.subscribeDidSaveNotes(target: self, action: #selector(didSaveNotes(_:)))
        DocumentController.subscribeDidOpenNotes(target: self, action: #selector(didOpenNotes(_:)))
        
        // Subscribe to display changes
        DisplayController.subscribeDisplayNavigator(target: self, action: #selector(displayNavigatorDidChange(_:)))
        DisplayController.subscribeDisplayPointer(target: self, action: #selector(displayPointerDidChange(_:)))
        DisplayController.subscribeDisplayCurtain(target: self, action: #selector(displayCurtainDidChange(_:)))
        DisplayController.subscribeDisplayDrawingTools(target: self, action: #selector(displayDrawingToolsDidChange(_:)))
        PreferencesController.subscribeTimeSize(target: self, action: #selector(timeSizeDidChange(_:)))
        
        // Subscribe to time changes
        TimeController.subscribeIsRunning(target: self, action: #selector(timeIsRunningDidChange(_:)))
        TimeController.subscribeTimeMode(target: self, action: #selector(timeModeDidChange(_:)))
        TimeController.subscribeReset(target: self, action: #selector(timeDidReset(_:)))
        TimeController.subscribeRequestTimerInterval(target: self, action: #selector(didRequestSetTimerInterval(_:)))
        
        // Setup additional auto layout constraint
        slideArrangementFullTopConst = NSLayoutConstraint(item: slideArrangement!, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0.0)
        self.view.addConstraint(slideArrangementFullTopConst)
        slideArrangementFullTopConst.isActive = false
        
        timeViewSmallHeightConstraint = NSLayoutConstraint(item: timeView!, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 0.13, constant: 0.0)
        self.view.addConstraint(timeViewSmallHeightConstraint)
        timeViewSmallHeightConstraint.isActive = false
        
        updateLayout()
    }
    
    
    func updateLayout() {
        // Update layout based on time control size preferences
        switch PreferencesController.timeSize {
        case .hidden:
            timeView.isHidden = true
            slideArrangementSharedTopConst.isActive = false
            slideArrangementFullTopConst.isActive = true
            
        case .small:
            timeView.isHidden = false
            slideArrangementFullTopConst.isActive = false
            slideArrangementSharedTopConst.isActive = true
            
            timeViewNormalHeightConstraint.isActive = false
            timeViewSmallHeightConstraint.isActive = true
            clockLabelHeight.constant = 70
            timingControlHeight.constant = 70
            clockLabel.font = NSFont.systemFont(ofSize: 55, weight: .light)
            timingControl.font = NSFont.systemFont(ofSize: 55, weight: .light)
            timingControlTopConstraint.constant = 5
            timingControlBottomConstraint.constant = 5
            clockLabelTopConstraint.constant = 5
            clockLabelBottomConstraint.constant = 5
            
        case .normal:
            timeView.isHidden = false
            slideArrangementFullTopConst.isActive = false
            slideArrangementSharedTopConst.isActive = true
            
            timeViewSmallHeightConstraint.isActive = false
            timeViewNormalHeightConstraint.isActive = true
            clockLabelHeight.constant = 85
            timingControlHeight.constant = 85
            clockLabel.font = NSFont.systemFont(ofSize: 70, weight: .light)
            timingControl.font = NSFont.systemFont(ofSize: 70, weight: .light)
            timingControlTopConstraint.constant = 20
            timingControlBottomConstraint.constant = 20
            clockLabelTopConstraint.constant = 20
            clockLabelBottomConstraint.constant = 20
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
    
    
    
    
    // MARK: - Control Handlers
    
    @objc func documentDidChange(_ notification: Notification) {
        hideNavigation(animated: false)
        DisplayController.setDisplayNavigator(false, sender: self)
    }
    
    
    @objc func didSaveNotes(_ notification: Notification) {
        guard let status = notification.userInfo?["status"] as? CompletionStatus else { return }
        // Show alert on failed save
        if status == .failed {
            let message = NSLocalizedString("Save Notes Failed", comment: "Alert message informing about failed saving notes..")
            let text = NSLocalizedString("Save Notes Failed Text", comment: "Alert text informing about failed saving notes..")
            let alertStyle = NSAlert.Style.critical
            showNotice(message: message, text: text, alertStyle: alertStyle)
        }
    }
    
    
    @objc func didOpenNotes(_ notification: Notification) {
        guard let success = notification.userInfo?["success"] as? Bool else { return }
        // Show alert on failed open
        if !success {
            let message = NSLocalizedString("Open Notes Failed", comment: "Alert message informing about failed opening.")
            let text = NSLocalizedString("Open Notes Failed Text", comment: "Alert text informing about failed opening.")
            let alertStyle = NSAlert.Style.critical
            showNotice(message: message, text: text, alertStyle: alertStyle)
        }
    }
    
    
    @objc func displayNavigatorDidChange(_ notification: Notification) {
        if DisplayController.isNavigatorDisplayed {
            showNavigation()
        } else {
            hideNavigation(animated: false)
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
    
    
    @objc func displayCurtainDidChange(_ notification: Notification) {
        if DisplayController.isCurtainDisplayed {
            showHiddenScreenNotice()
        } else {
            hideHiddenScreenNotice()
        }
    }
    
    
    @objc func displayDrawingToolsDidChange(_ notification: Notification) {
        if DisplayController.areDrawingToolsDisplayed {
            showDrawingToolbar()
        } else {
            hideDrawingToolbar()
        }
        
        if #available(OSX 10.12.2, *) {
            self.view.window?.windowController?.touchBar = nil
        }
    }
    
    
    @objc func timeSizeDidChange(_ notification: Notification) {
        updateLayout()
    }
    
    
    @objc func timeIsRunningDidChange(_ notification: Notification) {
        // Start/Stop timingControl depending on isRunning from TimeController
        if TimeController.isRunning {
            timingControl.start()
        } else {
            timingControl.stop()
        }
    }
    
    
    @objc func timeModeDidChange(_ notification: Notification) {
        // Set correct mode for timingControl
        timingControl.mode = TimeController.timeMode
    }
    
    
    @objc func timeDidReset(_ notification: Notification) {
        // Reset time on timingControl
        timingControl.reset()
    }
    
    
    @objc func didRequestSetTimerInterval(_ notification: Notification) {
        // Open the set timer popover
        openSetTimerDialog(completion: {
            TimeController.setIsRunning(false, sender: self)
        })
    }
    
    
    
    
    // MARK: - UI
    
    var hiddenScreenNotice: UserNotice?
    
    func showHiddenScreenNotice() {
        // Create notice if necessary
        if hiddenScreenNotice == nil {
            hiddenScreenNotice = UserNotice(style: .warning, message: NSLocalizedString("Hidden Screen Warning", comment: "Message for the warning notice, that the screen is hidden."))
            hiddenScreenNotice?.maxWidth = 250.0
        }
        hiddenScreenNotice?.show(in: self.view)
    }
    
    
    func hideHiddenScreenNotice() {
        hiddenScreenNotice?.hide()
    }
    
    
    func openSetTimerDialog(completion: @escaping()->()) {
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
                completion()
            }
        }
    }
    
    
    func showNotice(message: String, text: String, alertStyle: NSAlert.Style) {
        let alert = NSAlert()
        alert.messageText = message
        alert.informativeText = text
        alert.alertStyle = alertStyle
        alert.addButton(withTitle: NSLocalizedString("OK", comment: "Title for ok button."))
        alert.runModal()
    }
    
    
    func showDrawingToolbar() {
        if drawingToolbar == nil {
            drawingToolbar = DrawingToolbar()
        }
        drawingToolbar?.show(in: self.view)
    }
    
    
    func hideDrawingToolbar() {
        drawingToolbar?.hide()
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
        timingLeftConst.constant = navigationWidth
        slidesLeftConst.constant = navigationWidth
        self.view.updateConstraints()
        navigation?.searchField.becomeFirstResponder()
    }
    
    
    /** Hides the ThumbnailNavigation view. */
    func hideNavigation(animated: Bool) {
        guard navigation != nil, navigationLeft != nil else { return }
        navigationLeft!.constant = -navigationWidth
        timingLeftConst.constant = 0.0
        slidesLeftConst.constant = 0.0
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
            self.navigation?.removeFromSuperview()
            self.navigation = nil
        }
    }
    
    
    override func cancelOperation(_ sender: Any?) {
        DisplayController.setDisplayNavigator(false, sender: self)
        DisplayController.setDisplayDrawingTools(false, sender: self)
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
