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
    static let freezePresentationItem = NSTouchBarItem.Identifier("de.pascalbraband.TouchBarItem.freezePresentation")
    static let notesItem = NSTouchBarItem.Identifier("de.pascalbraband.TouchBarItem.notes")
    static let navigatorItem = NSTouchBarItem.Identifier("de.pascalbraband.TouchBarItem.navigator")
    static let pointerItem = NSTouchBarItem.Identifier("de.pascalbraband.TouchBarItem.pointerItem")
    static let pointerAppearancePopover = NSTouchBarItem.Identifier("de.pascalbraband.TouchBarItem.pointerAppearancePopover")
    static let previewNextSlideItem = NSTouchBarItem.Identifier("de.pascalbraband.TouchBarItem.previewNextSlideItem")
    
    static let pointerAppearanceCursorItem = NSTouchBarItem.Identifier("de.pascalbraband.TouchBarItem.pointerAppearancePopover")
    static let pointerAppearanceDotItem = NSTouchBarItem.Identifier("de.pascalbraband.TouchBarItem.pointerAppearanceDot")
    static let pointerAppearanceCircleItem = NSTouchBarItem.Identifier("de.pascalbraband.TouchBarItem.pointerAppearanceCircle")
    static let pointerAppearanceTargetItem = NSTouchBarItem.Identifier("de.pascalbraband.TouchBarItem.pointerAppearanceTarget")
    static let pointerAppearanceTargetColorItem = NSTouchBarItem.Identifier("de.pascalbraband.TouchBarItem.pointerAppearanceTargetColor")
}

@available(OSX 10.12.2, *)
extension NSTouchBar.CustomizationIdentifier {
    static let presentationBar = NSTouchBar.CustomizationIdentifier("de.pascalbraband.presentationBar")
}
