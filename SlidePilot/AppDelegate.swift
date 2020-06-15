//
//  AppDelegate.swift
//  SlidePilot
//
//  Created by Pascal Braband on 23.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa
import PDFKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // MARK: - Properties
    /** Indicates, whether the timer should be started on slide change. */
    var shouldStartTimerOnSlideChange = true
    
    
    // MARK: - Menu Outlets
    @IBOutlet weak var previousSlideItem: NSMenuItem!
    @IBOutlet weak var nextSlideItem: NSMenuItem!
    
    @IBOutlet weak var showNavigatorItem: NSMenuItem!
    @IBOutlet weak var previewNextSlideItem: NSMenuItem!
    @IBOutlet weak var displayBlackCurtainItem: NSMenuItem!
    @IBOutlet weak var displayWhiteCurtainItem: NSMenuItem!
    @IBOutlet weak var showPointerItem: NSMenuItem!
    @IBOutlet weak var showNotesItem: NSMenuItem!
    
    @IBOutlet weak var pointerAppearanceMenu: NSMenu!
    @IBOutlet weak var pointerAppearanceCursorItem: NSMenuItem!
    @IBOutlet weak var pointerAppearanceDotItem: NSMenuItem!
    @IBOutlet weak var pointerAppearanceCircleItem: NSMenuItem!
    @IBOutlet weak var pointerAppearanceTargetItem: NSMenuItem!
    @IBOutlet weak var pointerAppearanceTargetColorItem: NSMenuItem!
    
    @IBOutlet weak var notesModeMenu: NSMenu!
    @IBOutlet weak var notesModeTextItem: NSMenuItem!
    @IBOutlet weak var notesModeSplitItem: NSMenuItem!
    
    @IBOutlet weak var notesPositionMenu: NSMenu!
    @IBOutlet weak var notesPositionNoneItem: NSMenuItem!
    @IBOutlet weak var notesPositionRightItem: NSMenuItem!
    @IBOutlet weak var notesPositionLeftItem: NSMenuItem!
    @IBOutlet weak var notesPositionBottomItem: NSMenuItem!
    @IBOutlet weak var notesPositionTopItem: NSMenuItem!
    
    @IBOutlet weak var timeModeMenu: NSMenu!
    @IBOutlet weak var stopwatchModeItem: NSMenuItem!
    @IBOutlet weak var timerModeItem: NSMenuItem!
    @IBOutlet weak var setTimerItem: NSMenuItem!
    
    @IBOutlet weak var drawItem: NSMenuItem!
    @IBOutlet weak var clearCanvasItem: NSMenuItem!
    @IBOutlet weak var blankCanvasItem: NSMenuItem!
    
    
    // MARK: - Identifiers
    private let presenterWindowIdentifier = NSUserInterfaceItemIdentifier("PresenterWindowID")
    private let presentationWindowIdentifier = NSUserInterfaceItemIdentifier("PresentationWindowID")
    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Disable Tabs
        if #available(OSX 10.12, *) {
            NSWindow.allowsAutomaticWindowTabbing = false
        }
        
        // Enable TouchBar
        if #available(OSX 10.12.2, *) {
            NSApplication.shared.isAutomaticCustomizeTouchBarMenuItemEnabled = true
        }
        
        // Count app starts
        AppStartTracker.startup()
        
        // Subscribe to display changes
        DisplayController.subscribeNotesPosition(target: self, action: #selector(notesPositionDidChange(_:)))
        DisplayController.subscribeDisplayNotes(target: self, action: #selector(displayNotesDidChange(_:)))
        DisplayController.subscribeDisplayBlackCurtain(target: self, action: #selector(displayBlackCurtainDidChange(_:)))
        DisplayController.subscribeDisplayWhiteCurtain(target: self, action: #selector(displayWhiteCurtainDidChange(_:)))
        DisplayController.subscribeDisplayNavigator(target: self, action: #selector(displayNavigatorDidChange(_:)))
        DisplayController.subscribePreviewNextSlide(target: self, action: #selector(displayNextSlidePreviewDidChange(_:)))
        DisplayController.subscribeDisplayPointer(target: self, action: #selector(displayPointerDidChange(_:)))
        DisplayController.subscribePointerAppearance(target: self, action: #selector(pointerAppearanceDidChange(_:)))
        DisplayController.subscribeNotesMode(target: self, action: #selector(notesModeDidChange(_:)))
        DisplayController.subscribeDisplayDrawingTools(target: self, action: #selector(displayDrawingToolsDidChange(_:)))
        DisplayController.subscribeLayoutChangesEnabled(target: self, action: #selector(didChangeLayoutChangesEnabled(_:)))
        
        // Set default display options
        DisplayController.setPointerAppearance(.cursor, sender: self)
        
        // Subscribe to page controller changes
        PageController.subscribePageSwitchingEnabled(target: self, action: #selector(didChangePageSwitchingEnabled(_:)))
        
        // Subscribe to notes file changes
        DocumentController.subscribeRequestOpenNotes(target: self, action: #selector(didRequestOpenNotes(_:)))
        DocumentController.subscribeRequestSaveNotes(target: self, action: #selector(didRequestSaveNotes(_:)))
        DocumentController.subscribeDidEditNotes(target: self, action: #selector(didEditNotes(_:)))
        DocumentController.subscribeDidSaveNotes(target: self, action: #selector(didSaveNotes(_:)))
        DocumentController.subscribeDidOpenNotes(target: self, action: #selector(didOpenNotes(_:)))
        DocumentController.subscribeNewNotes(target: self, action: #selector(didCreateNewNotes(_:)))
        
        // Subscribe to time changes
        TimeController.subscribeTimeMode(target: self, action: #selector(timeModeDidChange(_:)))
        
        // Set default time options
        TimeController.setTimeMode(mode: .stopwatch, sender: self)
        
        // Subscribe to canvas changes
        CanvasController.subscribeCanvasBackgroundChanged(target: self, action: #selector(didChangeCanvasBackground(_:)))
        
        startup()
    }
    
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // Wait for saving to be completed until terminating application
        saveUnsavedChanges { (shouldContinue) in
            NSApp.reply(toApplicationShouldTerminate: shouldContinue)
        }
        
        return .terminateLater
    }
    
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    
    @IBAction func openHelpWebsite(_ sender: Any) {
        if #available(OSX 10.15, *) {
            let openConfig = NSWorkspace.OpenConfiguration()
            openConfig.addsToRecentItems = true
            NSWorkspace.shared.open(URL(string: "http://slidepilot.gitbook.io")!, configuration: openConfig, completionHandler: nil)
        } else {
            NSWorkspace.shared.open(URL(string: "http://slidepilot.gitbook.io")!)
        }
    }

    
    
    
    // MARK: - Window Management
    
    var presenterWindowCtrl: PresenterWindowController?
    var presenterWindow: NSWindow?
    var presenterDisplay: PresenterViewController?
    
    var presentationWindowCtrl: PresentationWindowController?
    var presentationWindow: NSWindow?
    var presentationView: PresentationViewController?
    
    
    func startup() {
        presentOpenFileDialog { (fileUrl) in
            setupWindows()
            openFile(url: fileUrl)
        }
    }
    
    
    func setupWindows() {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        
        guard let presenterWindowCtrl = storyboard.instantiateController(withIdentifier: .init(stringLiteral: "PresenterWindow")) as? PresenterWindowController else { return }
        guard let presenterWindow = presenterWindowCtrl.window else { return }
        guard let presenterDisplay = presenterWindowCtrl.contentViewController as? PresenterViewController else { return }
        
        guard let presentationWindowCtrl = storyboard.instantiateController(withIdentifier: .init(stringLiteral: "PresentationWindow")) as?
            PresentationWindowController else { return }
        guard let presentationWindow = presentationWindowCtrl.window else { return }
        guard let presentationView = presentationWindowCtrl.contentViewController as? PresentationViewController else { return }
        
        // Set window identifiers
        presenterWindow.identifier = presenterWindowIdentifier
        presentationWindow.identifier = presentationWindowIdentifier
        
        NSApp.activate(ignoringOtherApps: true)
        
        // Move window to second screen if possible
        if NSScreen.screens.count >= 2 {
            let secondScreen = NSScreen.screens[1]
            presentationWindow.setFrame(secondScreen.visibleFrame, display: true, animate: true)
            presentationWindow.level = .normal
        }
        
        // Setup communication between the two windows
        presenterDisplay.pointerDelegate = presentationView
        
        // Open Presentation Window in fullscreen
        presentationWindow.orderFront(self)
        presentationWindow.toggleFullScreen(self)
        
        // Open Presenter Display
        presenterWindow.makeKeyAndOrderFront(nil)
        
        // Set properties
        self.presenterWindowCtrl = presenterWindowCtrl
        self.presenterWindow = presenterWindow
        self.presenterDisplay = presenterDisplay
        
        self.presentationWindowCtrl = presentationWindowCtrl
        self.presentationWindow = presentationWindow
        self.presentationView = presentationView
    }
    
    
    
    
    // MARK: - Open File
    
    @IBAction func openDocument(_ sender: NSMenuItem) {
        presentOpenFileDialog { (fileUrl) in
            requestOpenFile(url: fileUrl)
        }
    }
    
    
    /** Presents the dialog to open a PDF document. */
    func presentOpenFileDialog(completion: (URL) -> ()) {
        let dialog = NSOpenPanel();

        dialog.title = NSLocalizedString("Choose File", comment: "Title for open file panel.");
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = false
        dialog.canCreateDirectories = false
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes = ["pdf"]

        if (dialog.runModal() == .OK) {
            if let result = dialog.url {
                completion(result)
            }
        }
    }
    
    
    func requestOpenFile(url: URL) {
        // Wait for saving to be completed until opening a new PDF document
        saveUnsavedChanges { (shouldContinue) in
            if shouldContinue {
                self.openFile(url: url)
            }
        }
    }
    
    
    /** Opens the PDF document at the given `URL` in both presenter and presentation window. */
    func openFile(url: URL) {
        NSDocumentController.shared.noteNewRecentDocumentURL(url)
        guard let pdfDocument = PDFDocument(url: url) else { return }
        
        // Open document
        DocumentController.setDocument(pdfDocument, sender: self)
        
        // Reset page
        PageController.selectPage(at: 0, sender: self)
        
        // Reset display options
        DisplayController.setDisplayNextSlidePreview(true, sender: self)
        DisplayController.setNotesPosition(.none, sender: self)
        DisplayController.setDisplayNotes(false, sender: self)
        DisplayController.setNotesMode(.text, sender: self)
        DisplayController.setDisplayDrawingTools(false, sender: self)
        DisplayController.enableLayoutChanges(true, sender: self)
        PageController.enablePageSwitching(true, sender: self)
        
        // Reset stopwatch/timer
        TimeController.resetTime(sender: self)
        
        // Reset property, that timer should start when chaning slide
        shouldStartTimerOnSlideChange = true
        
        // Open the notes document if it can be found
        if let notesURL = searchNotesDocument() {
            let notesDocument = NotesDocument(contentsOf: notesURL, pageCount: DocumentController.document?.pageCount ?? 0)
            DocumentController.didOpenNotes(document: notesDocument, sender: self)
            DisplayController.setDisplayNotes(true, sender: self)
        }
        // Create new document otherwise
        else {
            DocumentController.createNewNotesDocument(sender: self)
        }
    }
    
    
    /** Checks if a notes file exists for the PDF and returns the URL of it. Returns `nil` if no notes file was found. */
    func searchNotesDocument() -> URL? {
        guard let basePath = DocumentController.document?.documentURL?.deletingPathExtension().path else { return nil }
        
        let fileManager = FileManager.default
        let separators = ["-", "_", " "]
        let names = ["Notes", "notes", "Notizen"]
        let fileExtension = ".rtf"
        
        // Generate different options, example: basePath-Notes.rtf
        // Check if one of them exists and return it
        for separator in separators {
            for name in names {
                let option = basePath + separator + name + fileExtension
                if fileManager.fileExists(atPath: option) {
                    return URL(fileURLWithPath: option)
                }
            }
        }
        
        return nil
    }
    
    
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        requestOpenFile(url: URL(fileURLWithPath: filename))
        return true
    }
    
    
    /**
     First asks if unsaved changes should be saved and then performs either save or not. Then indicates the completion handler if actions can be continued or not.
     
     - parameters:
        - completion: Completion handler, which receives a `Bool` completion status `shouldContinue`, indicating whether the actual actions can be continued or not.
     */
    func saveUnsavedChanges(completion: @escaping (Bool) -> ()) {
        shouldSaveUnsavedChanges { (shouldSave) in
            // Wait for saving to be completed
            if shouldSave {
                DocumentController.requestSaveNotes(sender: self, completion: { (status) in
                    // If .success, call completion with true. Otherwise false.
                    completion(status == .success)
                })
            }
            // Can continue immediatly, if should not save (i.e. delete unsaved changes)
            else {
                completion(true)
            }
        }
    }
    
    
    /**
     Determines whether unsaved changes should be saved.
     Unsaved changes are always saved if the document has already been saved and has a URL.
     If notes document has no URL, user is asked what to do.
     
     - returns:
     Boolean value indicating, whether to save the unsaved changes or not.
     */
    func shouldSaveUnsavedChanges(completion: @escaping (Bool) -> ()) {
        if let notesDocument = DocumentController.notesDocument {
            // Only proceed if document has been edited
            if notesDocument.isDocumentEdited {
                // Prompt alert if document needs a filename to be saved
                if notesDocument.url == nil {
                    let alert = NSAlert()
                    alert.messageText = NSLocalizedString("Unsaved Changes", comment: "Message for unsaved changes alert.")
                    alert.informativeText = NSLocalizedString("Unsaved Changes Text", comment: "Text for unsaved changes alert.")
                    alert.alertStyle = .warning
                    alert.addButton(withTitle: NSLocalizedString("Save", comment: "Title for save button."))
                    alert.addButton(withTitle: NSLocalizedString("Delete", comment: "Title for delete button."))
                    
                    let res = alert.runModal()
                    if res == .alertFirstButtonReturn {
                        completion(true)
                        return
                    }
                }
                // Always save changes if notes document has already been saved to a file and has a URL to save to
                else {
                    completion(true)
                    return
                }
            }
        }
        completion(false)
    }
    
    
    
    
    // MARK: - Menu Item Actions
    
    @IBAction func increaseFontSize(_ sender: NSMenuItem) {
        TextFormatController.increaseFontSize(sender: sender)
    }
    
    
    @IBAction func decreaseFontSize(_ sender: NSMenuItem) {
        TextFormatController.decreaseFontSize(sender: sender)
    }

    
    @IBAction func previousSlide(_ sender: NSMenuItem) {
        PageController.previousPage(sender: self)
    }
    
    
    @IBAction func nextSlide(_ sender: NSMenuItem) {
        PageController.nextPage(sender: self)
        
        startTimerIfNeeded()
    }
    
    
    public func startTimerIfNeeded() {
        // If this is the first next slide call for this document, start time automatically
        if shouldStartTimerOnSlideChange {
            shouldStartTimerOnSlideChange = false
            TimeController.setIsRunning(true, sender: self)
        }
    }
    
    
    @IBAction func selectNotesPositionNone(_ sender: NSMenuItem) {
        // Publish changed notes position
        DisplayController.setNotesPosition(.none, sender: self)
    }
    
    
    @IBAction func selectNotesPositionRight(_ sender: NSMenuItem) {
        // Publish changed notes position
        DisplayController.setNotesPosition(.right, sender: self)
    }
    
    
    @IBAction func selectNotesPositionLeft(_ sender: NSMenuItem) {
        // Publish changed notes position
        DisplayController.setNotesPosition(.left, sender: self)
    }
    
    
    @IBAction func selectNotesPositionBottom(_ sender: NSMenuItem) {
        // Publish changed notes position
        DisplayController.setNotesPosition(.bottom, sender: self)
    }
    
    
    @IBAction func selectNotesPositionTop(_ sender: NSMenuItem) {
        // Publish changed notes position
        DisplayController.setNotesPosition(.top, sender: self)
    }
    
    
    @IBAction func showNotes(_ sender: NSMenuItem) {
        DisplayController.switchDisplayNotes(sender: sender)
    }
    
    @IBAction func selectNotesModeText(_ sender: NSMenuItem) {
        DisplayController.setNotesMode(.text, sender: sender)
    }
    
    
    @IBAction func selectNotesModeSplit(_ sender: NSMenuItem) {
        DisplayController.setNotesMode(.split, sender: sender)
    }
    
    
    @IBAction func newNotes(_ sender: NSMenuItem) {
        // Wait for saving to be completed until creating new notes document
        saveUnsavedChanges { (shouldContinue) in
            if shouldContinue {
                DocumentController.createNewNotesDocument(sender: self)
            }
        }
    }
    
    
    @IBAction func saveNotes(_ sender: NSMenuItem) {
        DocumentController.requestSaveNotes(sender: sender)
    }
    
    
    @IBAction func openNotes(_ sender: NSMenuItem) {
        // Wait for saving to be completed until opening new notes document
        saveUnsavedChanges { (shouldContinue) in
            if shouldContinue {
                DocumentController.requestOpenNotes(sender: sender)
            }
        }
    }
    
    
    @IBAction func displayBlackCurtain(_ sender: NSMenuItem) {
        DisplayController.switchDisplayBlackCurtain(sender: sender)
    }
    
    
    @IBAction func displayWhiteCurtain(_ sender: NSMenuItem) {
        DisplayController.switchDisplayWhiteCurtain(sender: sender)
    }
    
    
    @IBAction func showNavigator(_ sender: NSMenuItem) {
        DisplayController.switchDisplayNavigator(sender: sender)
    }
    
    @IBAction func previewNextSlide(_ sender: NSMenuItem) {
        DisplayController.switchDisplayNextSlidePreview(sender: sender)
    }
    
    
    @IBAction func showPointer(_ sender: NSMenuItem) {
        DisplayController.switchDisplayPointer(sender: sender)
    }
    
    
    @IBAction func selectPointerAppearanceCursor(_ sender: NSMenuItem) {
        DisplayController.setPointerAppearance(.cursor, sender: sender)
    }
    
    
    @IBAction func selectPointerAppearanceDot(_ sender: NSMenuItem) {
        DisplayController.setPointerAppearance(.dot, sender: sender)
    }
    
    
    @IBAction func selectPointerAppearanceCircle(_ sender: NSMenuItem) {
        DisplayController.setPointerAppearance(.circle, sender: sender)
    }
    
    
    @IBAction func selectPointerAppearanceTarget(_ sender: NSMenuItem) {
        DisplayController.setPointerAppearance(.target, sender: sender)
    }
    
    
    @IBAction func selectPointerAppearanceTargetColor(_ sender: NSMenuItem) {
        DisplayController.setPointerAppearance(.targetColor, sender: sender)
    }
    
    @IBAction func selectModeStopwatch(_ sender: NSMenuItem) {
        TimeController.setTimeMode(mode: .stopwatch, sender: self)
    }
    
    
    @IBAction func selectModeTimer(_ sender: NSMenuItem) {
        TimeController.setTimeMode(mode: .timer, sender: self)
    }
    
    
    @IBAction func setTimer(_ sender: NSMenuItem) {
        TimeController.requestSetTimerInterval(sender: self)
    }
    
    
    @IBAction func startStopTime(_ sender: NSMenuItem) {
        TimeController.switchIsRunning(sender: self)
        
        // Don't start time automatically anymore
        shouldStartTimerOnSlideChange = false
    }
    
    
    @IBAction func resetTime(_ sender: NSMenuItem) {
        TimeController.resetTime(sender: self)
    }
    
    
    @IBAction func showDrawTools(_ sender: NSMenuItem) {
        DisplayController.switchDisplayDrawingTools(sender: sender)
    }
    
    
    @IBAction func clearCanvas(_ sender: NSMenuItem) {
        CanvasController.clearCanvas(sender: sender)
    }
    
    
    @IBAction func blankCanvas(_ sender: NSMenuItem) {
        CanvasController.switchTransparentCanvas(sender: sender)
    }
    
    
    
    
    // MARK: - Control Handlers
    
    @objc func notesPositionDidChange(_ notification: Notification) {
        // Turn off all items in notes position menu
        notesPositionMenu.items.forEach({ $0.state = .off })
        
        // Select correct menu item for notes position
        switch DisplayController.notesPosition {
        case .none:
            notesPositionNoneItem.state = .on
            if DisplayController.areNotesDisplayed, DisplayController.notesMode == .split {
                DisplayController.setNotesMode(.text, sender: self)
            }
        case .right:
            notesPositionRightItem.state = .on
        case .left:
            notesPositionLeftItem.state = .on
        case .bottom:
            notesPositionBottomItem.state = .on
        case .top:
            notesPositionTopItem.state = .on
        }
    }
    
    
    @objc func notesModeDidChange(_ notification: Notification) {
        // Turn off all items in notes mode menu
        notesModeMenu.items.forEach({ $0.state = .off })
        
        // Select correct menu item for notes position
        switch DisplayController.notesMode {
        case .text:
            notesModeTextItem.state = .on
            
            // Reset notes position
            if DisplayController.areNotesDisplayed {
                DisplayController.setNotesPosition(.none, sender: self)
            }
            
        case .split:
            notesModeSplitItem.state = .on
            
            // Select notes position right by default when displaying notes split
            // Only if notes are displayed currently and current note position is none
            if DisplayController.areNotesDisplayed, DisplayController.notesPosition == .none , DisplayController.notesMode == .split{
                DisplayController.setNotesPosition(.right, sender: self)
            }
        }
    }
    
    
    @objc func didRequestOpenNotes(_ notification: Notification) {
        let dialog = NSOpenPanel();

        dialog.title = NSLocalizedString("Choose File", comment: "Title for open file panel.");
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = false
        dialog.canCreateDirectories = false
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes = ["rtf"]

        if (dialog.runModal() == .OK) {
            if let result = dialog.url {
                let notesDocument = NotesDocument(contentsOf: result, pageCount: DocumentController.document?.pageCount ?? 0)
                DocumentController.didOpenNotes(document: notesDocument, sender: self)
            }
        }
    }
    
    
    @objc func didRequestSaveNotes(_ notification: Notification) {
        // Check if document has already been saved, then save it to its url
        if DocumentController.notesDocument?.url != nil {
            let success = DocumentController.notesDocument?.save() ?? false
            DocumentController.didSaveNotes(status: CompletionStatus(success), sender: self)
        }
        
        // If document has not been saved yet, open the save panel
        else {
            // Compose predefined filename
            var notesFilename = "Notes.rtf"
            if let pdfFilename = DocumentController.document?.documentURL?.deletingPathExtension().lastPathComponent {
                let notesString = NSLocalizedString("Notes", comment: "Notes filename extension")
                notesFilename = pdfFilename + "-" + notesString + ".rtf"
                
            }
            
            let savePanel = NSSavePanel()
            savePanel.allowedFileTypes = ["rtf"]
            savePanel.canCreateDirectories = true
            savePanel.showsTagField = false
            savePanel.nameFieldStringValue = notesFilename
            savePanel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.modalPanelWindow)))
            
            savePanel.begin { (result) in
                if result == .OK {
                    var success = false
                    if let saveURL = savePanel.url {
                        // Start export notes to file using NotesAnnotation
                        success = DocumentController.notesDocument?.save(to: saveURL) ?? false
                    }
                    // Send notification, that export finished with success value
                    DocumentController.didSaveNotes(status: CompletionStatus(success), sender: self)
                } else {
                    DocumentController.didSaveNotes(status: .aborted, sender: self)
                }
            }
        }
    }
    
    
    @objc func didEditNotes(_ notification: Notification) {
        presenterWindowCtrl?.setDocumentEdited(true)
    }
    
    
    @objc func didSaveNotes(_ notification: Notification) {
        guard let status = notification.userInfo?["status"] as? CompletionStatus else { return }
        // Only update if saving notes was successfull
        if status == .success {
            presenterWindowCtrl?.setDocumentEdited(false)
        }
    }
    
    
    @objc func didOpenNotes (_ notification: Notification) {
        presenterWindowCtrl?.setDocumentEdited(false)
    }
    
    
    @objc func didCreateNewNotes (_ notification: Notification)  {
        presenterWindowCtrl?.setDocumentEdited(false)
    }
    
    
    @objc func displayNotesDidChange(_ notification: Notification) {
        // Set correct state for display notes menu item
        showNotesItem.state = DisplayController.areNotesDisplayed ? .on : .off
        
        
        // Select notes position right by default when displaying notes split
        // Only if notes are displayed currently and current note position is none
        if DisplayController.areNotesDisplayed, DisplayController.notesPosition == .none , DisplayController.notesMode == .split{
            DisplayController.setNotesPosition(.right, sender: self)
        }
    }
    
    
    @objc func displayBlackCurtainDidChange(_ notification: Notification) {
        // Set correct state for menu item
        displayBlackCurtainItem.state = DisplayController.isBlackCurtainDisplayed ? .on : .off
    }
    
    
    @objc func displayWhiteCurtainDidChange(_ notification: Notification) {
        // Set correct state for menu item
        displayWhiteCurtainItem.state = DisplayController.isWhiteCurtainDisplayed ? .on : .off
    }
    
    
    @objc func displayNavigatorDidChange(_ notification: Notification) {
        // Set correct state for menu item
        showNavigatorItem.state = DisplayController.isNavigatorDisplayed ? .on : .off
    }
    
    
    @objc func displayNextSlidePreviewDidChange(_ notifcation: Notification) {
        // Set correct state for menu item
        previewNextSlideItem.state = DisplayController.isNextSlidePreviewDisplayed ? .on : .off
    }
    
    
    @objc func displayPointerDidChange(_ notification: Notification) {
        // Set correct state for menu item
        showPointerItem.state = DisplayController.isPointerDisplayed ? .on : .off
    }
    
    
    @objc func pointerAppearanceDidChange(_ notification: Notification) {
        // Turn off all items in notes position menu
        pointerAppearanceMenu.items.forEach({ $0.state = .off })
        
        // Select correct menu item for notes position
        switch DisplayController.pointerAppearance {
        case .cursor:
            pointerAppearanceCursorItem.state = .on
        case .dot:
            pointerAppearanceDotItem.state = .on
        case .circle:
            pointerAppearanceCircleItem.state = .on
        case .target:
            pointerAppearanceTargetItem.state = .on
        case .targetColor:
            pointerAppearanceTargetColorItem.state = .on
        }
    }
    
    
    @objc func timeModeDidChange(_ notification: Notification) {
        // Turn off all items in mode menu
        timeModeMenu.items.forEach({ $0.state = .off })
        
        // Select correct menu item for notes position
        // Enable/Disable "Set Timer" menu item
        switch TimeController.timeMode {
        case .stopwatch:
            stopwatchModeItem.state = .on
            setTimerItem.isEnabled = false
        case .timer:
            timerModeItem.state = .on
            setTimerItem.isEnabled = true
        }
        
        TimeController.resetTime(sender: self)
    }
    
    
    @objc func displayDrawingToolsDidChange(_ notification: Notification) {
        drawItem.state = DisplayController.areDrawingToolsDisplayed ? .on : .off
        
        // Enable/Disable corresponding menu items
        clearCanvasItem.isEnabled = DisplayController.areDrawingToolsDisplayed
        blankCanvasItem.isEnabled = DisplayController.areDrawingToolsDisplayed
    }
    
    
    @objc func didChangeCanvasBackground(_ notification: Notification) {
        blankCanvasItem.state = CanvasController.isCanvasBackgroundTransparent ? .off : .on
    }
    
    
    @objc func didChangeLayoutChangesEnabled(_ notification: Notification) {
        // Enable/Disable menu items
        showNotesItem.isEnabled = DisplayController.areLayoutChangesEnabled
        previewNextSlideItem.isEnabled = DisplayController.areLayoutChangesEnabled
        showNavigatorItem.isEnabled = DisplayController.areLayoutChangesEnabled
    }
    
    
    @objc func didChangePageSwitchingEnabled(_ notification: Notification) {
        // Enable/Disable menu items
        previousSlideItem.isEnabled = PageController.isPageSwitchingEnabled
        nextSlideItem.isEnabled = PageController.isPageSwitchingEnabled
    }
}
