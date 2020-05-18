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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup default configuration
        
        // Subscribe to document changes
        DocumentController.subscribeDidOpenDocument(target: self, action: #selector(documentDidChange(_:)))
        DocumentController.subscribeRequestImportNotesFromFile(target: self, action: #selector(requestImportNotesFile(_:)))
        DocumentController.subscribeRequestImportNotesFromAnnotations(target: self, action: #selector(requestImportNotesAnnotations(_:)))
        DocumentController.subscribeRequestExportNotesToFile(target: self, action: #selector(requestExportNotes(_:)))
        DocumentController.subscribeFinishedImportingNotes(target: self, action: #selector(finishedImportNotes(_:)))
        DocumentController.subscribeFinishedExportingNotes(target: self, action: #selector(finishedExportNotes(_:)))
        DocumentController.subscribeDidSaveDocument(target: self, action: #selector(didSaveDocument(_:)))
        
        // Subscribe to display changes
        DisplayController.subscribeDisplayNavigator(target: self, action: #selector(displayNavigatorDidChange(_:)))
        DisplayController.subscribeDisplayPointer(target: self, action: #selector(displayPointerDidChange(_:)))
        DisplayController.subscribeDisplayCurtain(target: self, action: #selector(displayCurtainDidChange(_:)))
        DisplayController.subscribePresentationFrozen(target: self, action: #selector(presentationFrozenDidChange(_:)))
        
        // Subscribe to time changes
        TimeController.subscribeIsRunning(target: self, action: #selector(timeIsRunningDidChange(_:)))
        TimeController.subscribeTimeMode(target: self, action: #selector(timeModeDidChange(_:)))
        TimeController.subscribeReset(target: self, action: #selector(timeDidReset(_:)))
        TimeController.subscribeRequestTimerInterval(target: self, action: #selector(didRequestSetTimerInterval(_:)))
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
    
    
    @objc func displayCurtainDidChange(_ notification: Notification) {
        if DisplayController.isCurtainDisplayed {
            showHiddenScreenNotice()
        } else {
            hideHiddenScreenNotice()
        }
    }
    
    
    @objc func presentationFrozenDidChange(_ notification: Notification) {
        if DisplayController.isPresentationFrozen {
            showFrozenScreenNotice()
        } else {
            hideFrozenScreenNotice()
        }
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
    
    
    @objc func requestImportNotesFile(_ notification: Notification) {
        showImportAlert { (result) in
            if result {
                // Open file dialog
                let openPanel = NSOpenPanel()
                openPanel.title = NSLocalizedString("Choose File", comment: "Title for open file panel.");
                openPanel.showsResizeIndicator = true
                openPanel.showsHiddenFiles = false
                openPanel.canChooseFiles = true
                openPanel.canChooseDirectories = false
                openPanel.canCreateDirectories = false
                openPanel.allowsMultipleSelection = false
                openPanel.allowedFileTypes = ["txt"]
                
                openPanel.begin { (result) in
                    if result == .OK {
                        var success = false
                        if let notesURL = openPanel.url {
                            // Start import from file using NotesAnnotation
                            success = NotesAnnotation.importNotes(from: notesURL)
                        }
                        // Send notification, that import finished with success value
                        DocumentController.finishedImportingNotes(success: success, sender: self)
                    }
                }
            }
        }
    }
    
    
    @objc func requestImportNotesAnnotations(_ notification: Notification) {
        showImportAlert { (result) in
            if result {
                // Start import from annotations using NotesAnnotation
                let success = NotesAnnotation.importNotesFromAnnotationForDocument()
                // Send notification, that import finished with success value
                DocumentController.finishedImportingNotes(success: success, sender: self)
            }
        }
    }
    
    
    @objc func requestExportNotes(_ notification: Notification) {
        // Open save panel to select export file
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.showsTagField = false
        savePanel.nameFieldStringValue = "notes.txt"
        savePanel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.modalPanelWindow)))
        
        savePanel.begin { (result) in
            if result == .OK {
                var success = false
                if let saveURL = savePanel.url {
                    // Start export notes to file using NotesAnnotation
                    success = NotesAnnotation.exportNotes(to: saveURL)
                }
                // Send notification, that export finished with success value
                DocumentController.finishedExportingNotes(success: success, sender: self)
            }
        }
    }
    
    
    @objc func finishedImportNotes(_ notification: Notification) {
        guard let success = notification.userInfo?["success"] as? Bool else { return }
        // Show alert on failed import
        if !success {
            let message = NSLocalizedString("Import Failed", comment: "Alert message informing about failed import.")
            let text = NSLocalizedString("Import Failed Text", comment: "Alert text informing about failed import.")
            let alertStyle = NSAlert.Style.critical
            showNotice(message: message, text: text, alertStyle: alertStyle)
        }
    }
    
    
    @objc func finishedExportNotes(_ notification: Notification) {
        guard let success = notification.userInfo?["success"] as? Bool else { return }
        // Show alert on failed export
        if !success {
            let message = NSLocalizedString("Export Failed", comment: "Alert message informing about failed export.")
            let text = NSLocalizedString("Export Failed Text", comment: "Alert text informing about failed export.")
            let alertStyle = NSAlert.Style.critical
            showNotice(message: message, text: text, alertStyle: alertStyle)
        }
    }
    
    
    @objc func didSaveDocument(_ notification: Notification) {
        guard let success = notification.userInfo?["success"] as? Bool else { return }
        // Show alert on failed save
        if !success {
            let message = NSLocalizedString("Save Failed", comment: "Alert message informing about failed save.")
            let text = NSLocalizedString("Save Failed Text", comment: "Alert text informing about failed save.")
            let alertStyle = NSAlert.Style.critical
            showNotice(message: message, text: text, alertStyle: alertStyle)
        }
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
    
    
    var frozenScreenNotice: UserNotice?
    
    func showFrozenScreenNotice() {
        // Create notice if necessary
        if frozenScreenNotice == nil {
            frozenScreenNotice = UserNotice(style: .warning, message: NSLocalizedString("Frozen Presentation Warning", comment: "Message for the warning notice, that the presentation is frozen."))
            frozenScreenNotice?.maxWidth = 270.0
        }
        frozenScreenNotice?.show(in: self.view)
    }
    
    
    func hideFrozenScreenNotice() {
        frozenScreenNotice?.hide()
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
    
    
    func showImportAlert(completion: @escaping(Bool)->()) {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("Import Warning", comment: "Alert message warning for import.")
        alert.informativeText = NSLocalizedString("Import Warning Text", comment: "Alert text warning for import.")
        alert.alertStyle = NSAlert.Style.warning
        alert.addButton(withTitle: NSLocalizedString("OK", comment: "Title for ok button."))
        alert.addButton(withTitle: NSLocalizedString("Cancel", comment: "Title for cancel button."))
        
        let result = alert.runModal()
        if result == .alertFirstButtonReturn {
            completion(true)
        } else {
            completion(false)
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
