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
    
    private let defaultDarkModeKey = "defaultDarkMode"
    var defaultDarkMode: Bool = false {
        didSet {
            if defaultDarkMode {
                NSApp.appearance = NSAppearance(named: .darkAqua)
            } else {
                NSApp.appearance = nil
            }
            UserDefaults.standard.set(self.defaultDarkMode, forKey: defaultDarkModeKey)
        }
    }
    
    var presentationMenu: NSMenu? {
        NSApp.menu?.items.first(where: { $0.identifier == NSUserInterfaceItemIdentifier(rawValue: "PresentationMenu") })?.submenu
    }
    
    var viewMenu: NSMenu? {
        NSApp.menu?.items.first(where: { $0.identifier == NSUserInterfaceItemIdentifier(rawValue: "ViewMenu") })?.submenu
    }




    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        NSWindow.allowsAutomaticWindowTabbing = false
        
        // Load preferences from UserDefaults if possible
        let userDefaultsDarkMode = (UserDefaults.standard.object(forKey: defaultDarkModeKey) as? Bool) ?? false
        if let darkDefaultItem = viewMenu?.items.first(where: { $0.identifier == NSUserInterfaceItemIdentifier(rawValue: "DefaultDarkAppearance")}) {
            setDarkModeDefault(userDefaultsDarkMode, sender: darkDefaultItem)
        }
        
        startup()
    }
    

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    
    @IBAction func defaultDarkMode(_ sender: NSMenuItem) {
        setDarkModeDefault(!defaultDarkMode, sender: sender)
    }
    
    
    func setDarkModeDefault(_ isDefault: Bool, sender: NSMenuItem) {
        defaultDarkMode = isDefault
        sender.state = defaultDarkMode ? .on : .off
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
        
        // Open document in both windows
        presenterDisplay?.slideArrangement.pdfDocument = pdfDocument
        presentationView?.pageView.pdfDocument = pdfDocument
    }
    
    
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        openFile(url: URL(fileURLWithPath: filename))
        return true
    }
    
    
    
    // MARK: - Handling Slides
    
    @IBAction func previousSlide(_ sender: NSMenuItem) {
        presenterDisplay?.slideArrangement.previousSlide()
        presentationView?.pageView.pageBackward()
    }
    
    
    @IBAction func nextSlide(_ sender: NSMenuItem) {
        presenterDisplay?.slideArrangement.nextSlide()
        presentationView?.pageView.pageForward()
    }
    
    
    @IBAction func selectNotesPositionNone(_ sender: NSMenuItem) {
        // Turn off all menu items in same menu
        sender.menu?.items.forEach({ $0.state = .off })
        sender.state = .on
        
        presenterDisplay?.slideArrangement.notesPosition = .none
        presentationView?.pageView.displayMode = .displayModeForPresentation(with: .none)
    }
    
    
    @IBAction func selectNotesPositionRight(_ sender: NSMenuItem) {
        // Turn off all menu items in same menu
        sender.menu?.items.forEach({ $0.state = .off })
        sender.state = .on
        
        presenterDisplay?.slideArrangement.notesPosition = .right
        presentationView?.pageView.displayMode = .displayModeForPresentation(with: .right)
    }
    
    
    @IBAction func selectNotesPositionLeft(_ sender: NSMenuItem) {
        // Turn off all menu items in same menu
        sender.menu?.items.forEach({ $0.state = .off })
        sender.state = .on
        
        presenterDisplay?.slideArrangement.notesPosition = .left
        presentationView?.pageView.displayMode = .displayModeForPresentation(with: .left)
    }
    
    
    @IBAction func selectNotesPositionBottom(_ sender: NSMenuItem) {
        // Turn off all menu items in same menu
        sender.menu?.items.forEach({ $0.state = .off })
        sender.state = .on
        
        presenterDisplay?.slideArrangement.notesPosition = .bottom
        presentationView?.pageView.displayMode = .displayModeForPresentation(with: .bottom)
    }
    
    
    @IBAction func selectNotesPositionTop(_ sender: NSMenuItem) {
        // Turn off all menu items in same menu
        sender.menu?.items.forEach({ $0.state = .off })
        sender.state = .on
        
        presenterDisplay?.slideArrangement.notesPosition = .top
        presentationView?.pageView.displayMode = .displayModeForPresentation(with: .top)
    }
    
    
    @IBAction func displayWhiteScreen(_ sender: NSMenuItem) {
        // Uncheck other item
        if let whiteScreenItem = sender.menu?.items.first(where: { $0.identifier == NSUserInterfaceItemIdentifier(rawValue: "DisplayBlackScreen") }) {
            whiteScreenItem.state = .off
        }
        
        guard let isCovered = presentationView?.pageView.isCoveredWhite else { return }
        
        // Cover or uncover
        if isCovered {
            presentationView?.pageView.uncover()
            sender.state = .off
        } else {
            presentationView?.pageView.coverWhite()
            sender.state = .on
        }
    }
    
    
    @IBAction func displayBlackScreen(_ sender: NSMenuItem) {
        // Uncheck other item
        if let whiteScreenItem = sender.menu?.items.first(where: { $0.identifier == NSUserInterfaceItemIdentifier(rawValue: "DisplayWhiteScreen") }) {
            whiteScreenItem.state = .off
        }
        
        guard let isCovered = presentationView?.pageView.isCoveredBlack else { return }
        
        // Cover or uncover
        if isCovered {
            presentationView?.pageView.uncover()
            sender.state = .off
        } else {
            presentationView?.pageView.coverBlack()
            sender.state = .on
        }
    }
}