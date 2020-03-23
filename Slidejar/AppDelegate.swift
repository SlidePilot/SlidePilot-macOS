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
    
    var darkModeDefault: Bool = false {
        didSet {
            if darkModeDefault {
                NSApp.appearance = NSAppearance(named: .darkAqua)
            } else {
                NSApp.appearance = nil
            }
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
        
        if let darkDefaultItem = viewMenu?.items.first(where: { $0.identifier == NSUserInterfaceItemIdentifier(rawValue: "DefaultDarkAppearance")}) {
            setDarkModeDefault(false, sender: darkDefaultItem)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    
    @IBAction func defaultDarkMode(_ sender: NSMenuItem) {
        setDarkModeDefault(!darkModeDefault, sender: sender)
    }
    
    
    func setDarkModeDefault(_ isDefault: Bool, sender: NSMenuItem) {
        darkModeDefault = isDefault
        sender.state = darkModeDefault ? .on : .off
    }


}
