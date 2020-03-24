//
//  AppDelegate.swift
//  Slidejar
//
//  Created by Pascal Braband on 23.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

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
        
        setupWindows()
    }
    
    
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        print(filename)
        (NSApp.windows[0].contentViewController as? PresenterViewController)?.openFile(url: URL(fileURLWithPath: filename))
        return true
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
    
    func setupWindows() {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        
        guard let presenterWindow = storyboard.instantiateController(withIdentifier: .init(stringLiteral: "PresenterWindow")) as? PresenterWindowController else { return }
        guard let presenterDisplay = presenterWindow.contentViewController as? PresenterViewController else { return }
        
        guard let presentationWindow = storyboard.instantiateController(withIdentifier: .init(stringLiteral: "PresentationWindow")) as? PresentationWindowController else { return }
        guard let presentationView = presentationWindow.contentViewController as? PresentationViewController else { return }
        
        NSApp.activate(ignoringOtherApps: true)
        
        presenterWindow.window?.makeKeyAndOrderFront(nil)
        presentationWindow.window?.makeKeyAndOrderFront(nil)
        
//        presentationWindow.window?.toggleFullScreen(self)
    }

}
