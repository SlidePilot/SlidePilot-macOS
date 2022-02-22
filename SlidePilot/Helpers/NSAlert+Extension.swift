//
//  NSAlert+Extension.swift
//  SlidePilot
//
//  Created by Pascal Braband on 22.02.22.
//  Copyright © 2022 Pascal Braband. All rights reserved.
//

import Cocoa

extension NSAlert {
    
    public static func showWarning(message: String, text: String) {
        let alert = NSAlert()
        alert.messageText = message
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: NSLocalizedString("OK", comment: "Title for ok button."))
        
        let _ = alert.runModal()
    }
}
