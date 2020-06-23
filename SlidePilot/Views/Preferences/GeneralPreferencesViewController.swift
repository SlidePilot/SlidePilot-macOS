//
//  GeneralPreferencesViewController.swift
//  SlidePilot
//
//  Created by Pascal Braband on 23.06.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa
import Preferences

class GeneralPreferencesViewController: NSViewController, PreferencePane {

    let preferencePaneIdentifier = Preferences.PaneIdentifier.general
    let preferencePaneTitle = NSLocalizedString("General", comment: "Title for general preferences.")
    let toolbarItemIcon = NSImage(named: NSImage.preferencesGeneralName)!

    override var nibName: NSNib.Name? { "GeneralPreferences" }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup stuff here
    }
    
}
