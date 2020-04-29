//
//  TouchBarIdentifiers.swift
//  SlidePilot
//
//  Created by Pascal Braband on 28.04.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

@available(OSX 10.12.2, *)
extension NSTouchBarItem.Identifier {
    static let blackCurtainItem = NSTouchBarItem.Identifier("de.pascalbraband.TouchBarItem.blackCurtain")
    static let whiteCurtainItem = NSTouchBarItem.Identifier("de.pascalbraband.TouchBarItem.whiteCurtain")
    static let notesItem = NSTouchBarItem.Identifier("de.pascalbraband.TouchBarItem.notes")
    static let navigatorItem = NSTouchBarItem.Identifier("de.pascalbraband.TouchBarItem.navigator")
    static let cursorGroup = NSTouchBarItem.Identifier("de.pascalbraband.TouchBarItem.cursorGroup")
    static let cursorItem = NSTouchBarItem.Identifier("de.pascalbraband.TouchBarItem.cursorItem")
    static let cursorAppearancePopover = NSTouchBarItem.Identifier("de.pascalbraband.TouchBarItem.cursorAppearancePopover")
}

@available(OSX 10.12.2, *)
extension NSTouchBar.CustomizationIdentifier {
    static let presentationBar = NSTouchBar.CustomizationIdentifier("de.pascalbraband.presentationBar")
}
