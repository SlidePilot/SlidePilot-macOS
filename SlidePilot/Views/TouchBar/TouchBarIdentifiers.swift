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
    static let pointerItem = NSTouchBarItem.Identifier("de.pascalbraband.TouchBarItem.pointerItem")
    static let pointerAppearancePopover = NSTouchBarItem.Identifier("de.pascalbraband.TouchBarItem.pointerAppearancePopover")
    static let previewNextSlideItem = NSTouchBarItem.Identifier("de.pascalbraband.TouchBarItem.previewNextSlideItem")
    static let drawItem = NSTouchBarItem.Identifier("de.pascalbraband.TouchBarItem.drawItem")
    static let drawingColorItem = NSTouchBarItem.Identifier("de.pascalbraband.TouchBarItem.drawingColorItem")
    static let eraserItem = NSTouchBarItem.Identifier("de.pascalbraband.TouchBarItem.eraserItem")
    static let closeItem = NSTouchBarItem.Identifier("de.pascalbraband.TouchBarItem.closeItem")
    
    static let pointerAppearanceCursorItem = NSTouchBarItem.Identifier("de.pascalbraband.TouchBarItem.pointerAppearanceCursor")
    static let pointerAppearanceHandItem = NSTouchBarItem.Identifier("de.pascalbraband.TouchBarItem.pointerAppearanceHand")
    static let pointerAppearanceDotItem = NSTouchBarItem.Identifier("de.pascalbraband.TouchBarItem.pointerAppearanceDot")
    static let pointerAppearanceCircleItem = NSTouchBarItem.Identifier("de.pascalbraband.TouchBarItem.pointerAppearanceCircle")
    static let pointerAppearanceTargetItem = NSTouchBarItem.Identifier("de.pascalbraband.TouchBarItem.pointerAppearanceTarget")
    static let pointerAppearanceTargetColorItem = NSTouchBarItem.Identifier("de.pascalbraband.TouchBarItem.pointerAppearanceTargetColor")
    static let pointerAppearanceIndividualItem = NSTouchBarItem.Identifier("de.pascalbraband.TouchBarItem.pointerAppearanceIndividual")
}

@available(OSX 10.12.2, *)
extension NSTouchBar.CustomizationIdentifier {
    static let presentationBar = NSTouchBar.CustomizationIdentifier("de.pascalbraband.presentationBar")
}
