//
//  RemotePreferencesViewController.swift
//  SlidePilot
//
//  Created by Pascal Braband on 07.10.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa
import Preferences

class RemotePreferencesViewController: NSViewController, PreferencePane {
    
    let preferencePaneIdentifier = Preferences.PaneIdentifier.remote
    let preferencePaneTitle = NSLocalizedString("Remote", comment: "Title for remote preferences.")
    let toolbarItemIcon = NSImage(named: "RemoteIcon")!

    override var nibName: NSNib.Name? { "RemotePreferences" }
    
    
    // MARK: - UI Elements
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}


