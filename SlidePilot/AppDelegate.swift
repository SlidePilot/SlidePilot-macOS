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
    
    // MARK: - Menu Outlets
    @IBOutlet weak var showNavigatorItem: NSMenuItem!
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
    
    @IBOutlet weak var notesPositionMenu: NSMenu!
    @IBOutlet weak var notesPositionNoneItem: NSMenuItem!
    @IBOutlet weak var notesPositionRightItem: NSMenuItem!
    @IBOutlet weak var notesPositionLeftItem: NSMenuItem!
    @IBOutlet weak var notesPositionBottomItem: NSMenuItem!
    @IBOutlet weak var notesPositionTopItem: NSMenuItem!
    


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
        DisplayController.subscribeDisplayPointer(target: self, action: #selector(displayPointerDidChange(_:)))
        DisplayController.subscribePointerAppearance(target: self, action: #selector(pointerAppearanceDidChange(_:)))
        
        // Set default display options
        DisplayController.setPointerAppearance(.cursor, sender: self)
        
        startup()
    }
    

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
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
            openFile(url: fileUrl)
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
    
    
    /** Opens the PDF document at the given `URL` in both presenter and presentation window. */
    func openFile(url: URL) {
        NSDocumentController.shared.noteNewRecentDocumentURL(url)
        guard let pdfDocument = PDFDocument(url: url) else { return }
        
        // Reset page
        PageController.selectPage(at: 0, sender: self)
        
        // Reset display options
        DisplayController.setNotesPosition(.none, sender: self)
        DisplayController.setDisplayNotes(false, sender: self)
        
        // Open document
        DocumentController.setDocument(pdfDocument, sender: self)
    }
    
    
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        openFile(url: URL(fileURLWithPath: filename))
        return true
    }
    
    
    
    // MARK: - Handling Slides
    
    @IBAction func previousSlide(_ sender: NSMenuItem) {
        PageController.previousPage(sender: self)
    }
    
    
    @IBAction func nextSlide(_ sender: NSMenuItem) {
        PageController.nextPage(sender: self)
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
    
    
    @IBAction func displayBlackCurtain(_ sender: NSMenuItem) {
        DisplayController.switchDisplayBlackCurtain(sender: sender)
    }
    
    
    @IBAction func displayWhiteCurtain(_ sender: NSMenuItem) {
        DisplayController.switchDisplayWhiteCurtain(sender: sender)
    }
    
    
    @IBAction func showNavigator(_ sender: NSMenuItem) {
        DisplayController.switchDisplayNavigator(sender: sender)
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
    
    
    
    
    // MARK: - Control Handlers
    
    @objc func notesPositionDidChange(_ notification: Notification) {
        // Turn off all items in notes position menu
        notesPositionMenu.items.forEach({ $0.state = .off })
        
        // Set correct menu item identifier for notes position
        switch DisplayController.notesPosition {
        case .none:
            notesPositionNoneItem.state = .on
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
    
    
    @objc func displayNotesDidChange(_ notification: Notification) {
        // Set correct state for display notes menu item
        showNotesItem.state = DisplayController.areNotesDisplayed ? .on : .off
        
        
        // Select notes position right by default when displaying notes
        // Only if notes are displayed currently and current note position is none
        if DisplayController.areNotesDisplayed, DisplayController.notesPosition == .none {
            DisplayController.setNotesPosition(.right, sender: self)
        }
        
        // Enable selecting notes position none when notes ARE NOT displayed
        // Disable selecting notes position none when notes ARE displayed
        notesPositionNoneItem.isEnabled = !DisplayController.areNotesDisplayed
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
    
    
    @objc func displayPointerDidChange(_ notification: Notification) {
        // Set correct state for menu item
        showPointerItem.state = DisplayController.isPointerDisplayed ? .on : .off
    }
    
    
    @objc func pointerAppearanceDidChange(_ notification: Notification) {
        // Turn off all items in notes position menu
        pointerAppearanceMenu.items.forEach({ $0.state = .off })
        
        // Set correct menu item identifier for notes position
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
}
