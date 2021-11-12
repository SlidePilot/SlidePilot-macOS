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
    let toolbarItemIcon = NSImage(named: "GeneralIcon")!

    override var nibName: NSNib.Name? { "GeneralPreferences" }
    
    
    // MARK: - UI Elements
    @IBOutlet weak var awakeCheckBox: NSButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // UI Elements with preferences
        awakeCheckBox.state = PreferencesController.isSleepDisabled ? .on : .off
    }
    
    
    @IBAction func awakeCheckBoxPressed(_ sender: NSButton) {
        if sender.state == .on {
            PreferencesController.disableSleep()
        } else {
            PreferencesController.enableSleep()
        }
    }
    
    
    
}
