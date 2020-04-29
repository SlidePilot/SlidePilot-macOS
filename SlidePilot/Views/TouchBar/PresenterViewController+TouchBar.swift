//
//  PresenterViewController+TouchBar.swift
//  SlidePilot
//
//  Created by Pascal Braband on 28.04.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

@available(OSX 10.12.2, *)
extension PresenterViewController: NSTouchBarDelegate {
    
    override func makeTouchBar() -> NSTouchBar? {
        // Create TouchBar and assign delegate
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        
        
        touchBar.customizationIdentifier = .presentationBar
        touchBar.defaultItemIdentifiers = [.blackCurtainItem, .whiteCurtainItem, .notesItem, .navigatorItem, .fixedSpaceLarge, .cursorGroup]
        touchBar.customizationAllowedItemIdentifiers = [.blackCurtainItem, .whiteCurtainItem, .notesItem, .navigatorItem, .fixedSpaceLarge, .cursorGroup]
        return touchBar
    }
    
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier {
            
        case .blackCurtainItem:
            let item = NSCustomTouchBarItem(identifier: identifier)
//            let button = NSButton(
//                image: NSImage(named: "BlackCurtain")!,
//                target: self,
//                action: #selector(touchBarBlackCurtainPressed(_:)))
            let button = NSSegmentedControl(
                images: [NSImage(named: "BlackCurtain")!],
                trackingMode: .selectAny,
                target: self,
                action: #selector(touchBarBlackCurtainPressed))
            item.view = button
            return item
            
        case .whiteCurtainItem:
            let item = NSCustomTouchBarItem(identifier: identifier)
            let button = NSSegmentedControl(
                images: [NSImage(named: "WhiteCurtain")!],
                trackingMode: .selectAny,
                target: self,
                action: #selector(touchBarWhiteCurtainPressed(_:)))
            item.view = button
            return item
            
        case .notesItem:
            let item = NSCustomTouchBarItem(identifier: identifier)
            let button = NSSegmentedControl(
                images: [NSImage(named: NSImage.touchBarTextListTemplateName)!],
                trackingMode: .selectAny,
                target: self,
                action: #selector(touchBarNotesPressed(_:)))
            item.view = button
            return item
            
        case .navigatorItem:
            let item = NSCustomTouchBarItem(identifier: identifier)
            let button = NSSegmentedControl(
                images: [NSImage(named: NSImage.touchBarOpenInBrowserTemplateName)!],
                trackingMode: .selectAny,
                target: self,
                action: #selector(touchBarCursorPressed(_:)))
            item.view = button
            return item
            
            
        case .cursorGroup:
            // Setup show/hide cursor button
            let cursorItem = NSCustomTouchBarItem(identifier: .cursorItem)
            let cursorButton = NSSegmentedControl(
                images: [NSImage(named: "Cursor")!],
                trackingMode: .selectAny,
                target: self,
                action: #selector(touchBarCursorPressed(_:)))
            cursorItem.view = cursorButton
            
            
            // Setup appearance popover            
            let appearancePopover = NSPopoverTouchBarItem(identifier: .cursorAppearancePopover)
            appearancePopover.showsCloseButton = true
            appearancePopover.collapsedRepresentationImage = NSImage(named: NSImage.touchBarQuickLookTemplateName)!
            appearancePopover.popoverTouchBar = CursorAppearanceTouchBar()
            
            let group = NSGroupTouchBarItem(identifier: identifier, items: [cursorItem, appearancePopover])
            
            return group
            
        default:
            return nil
        }
    }
    
    
    @objc func touchBarBlackCurtainPressed(_ sender: NSButton) {
        print("black curtain")
    }
    
    
    @objc func touchBarWhiteCurtainPressed(_ sender: NSButton) {
        print("white curtain")
    }
    
    
    @objc func touchBarNotesPressed(_ sender: NSButton) {
        print("notes")
    }
    
    
    @objc func touchBarNavigatorPressed(_ sender: NSButton) {
        print("navigator")
    }
    
    
    @objc func touchBarCursorPressed(_ sender: NSButton) {
        print("cursor")
    }
    
    
    @objc func touchBarCursorAppearancePressed(_ sender: NSButton) {
        print("cursor appearance")
    }
}
