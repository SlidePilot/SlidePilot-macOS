//
//  PointerAppearanceTouchBar.swift
//  SlidePilot
//
//  Created by Pascal Braband on 28.04.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

@available(OSX 10.12.2, *)
class PointerAppearanceTouchBar: NSTouchBar, NSTouchBarDelegate {
    
    override init() {
        super.init()
        setupTouchBar()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTouchBar()
    }
    
    
    func setupTouchBar() {
        delegate = self
        defaultItemIdentifiers = [.pointerAppearanceCursorItem, .pointerAppearanceDotItem, .pointerAppearanceCircleItem, .pointerAppearanceTargetItem, .pointerAppearanceTargetColorItem]
        DisplayController.subscribePointerAppearance(target: self, action: #selector(pointerAppearanceDidChangeTouchBar(_:)))
        
        // Setup initial selection
        updateButtons()
    }
    
    
    
    // MARK: - Control Handlers
    
    @objc func pointerAppearanceDidChangeTouchBar(_ notification: Notification) {
        updateButtons()
    }
    
    
    func updateButtons() {
        // Deselect all items
        guard let cursorButton = self.item(forIdentifier: .pointerAppearanceCursorItem)?.view as? NSSegmentedControl else { return }
        guard let dotButton = self.item(forIdentifier: .pointerAppearanceDotItem)?.view as? NSSegmentedControl else { return }
        guard let circleButton = self.item(forIdentifier: .pointerAppearanceCircleItem)?.view as? NSSegmentedControl else { return }
        guard let targetButton = self.item(forIdentifier: .pointerAppearanceTargetItem)?.view as? NSSegmentedControl else { return }
        guard let targetColorButton = self.item(forIdentifier: .pointerAppearanceTargetColorItem)?.view as? NSSegmentedControl else { return }
        
        setSelected(button: cursorButton, false)
        setSelected(button: dotButton, false)
        setSelected(button: circleButton, false)
        setSelected(button: targetButton, false)
        setSelected(button: targetColorButton, false)
        
        // Select the correct item based on the current pointer appearance
        switch DisplayController.pointerAppearance {
        case .cursor:
            setSelected(button: cursorButton, true)
        case .dot:
            setSelected(button: dotButton, true)
        case .circle:
            setSelected(button: circleButton, true)
        case .target:
            setSelected(button: targetButton, true)
        case .targetColor:
            setSelected(button: targetColorButton, true)
        }
    }

    
    
    
    // MARK: - TouchBar
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier {
            
        case .pointerAppearanceCursorItem:
            let item = NSCustomTouchBarItem(identifier: identifier)
            let button = NSSegmentedControl(
                images: [NSImage(named: "Cursor")!],
                trackingMode: .selectAny,
                target: self,
                action: #selector(touchBarPointerAppearanceCursorPressed(_:)))
            item.view = button
            return item
            
        case .pointerAppearanceDotItem:
            let item = NSCustomTouchBarItem(identifier: identifier)
            let button = NSSegmentedControl(
                images: [NSImage(named: "Dot")!],
                trackingMode: .selectAny,
                target: self,
                action: #selector(touchBarPointerAppearanceDotPressed(_:)))
            item.view = button
            return item
            
        case .pointerAppearanceCircleItem:
            let item = NSCustomTouchBarItem(identifier: identifier)
            let button = NSSegmentedControl(
                images: [NSImage(named: "Circle")!],
                trackingMode: .selectAny,
                target: self,
                action: #selector(touchBarPointerAppearanceCirclePressed(_:)))
            item.view = button
            return item
            
        case .pointerAppearanceTargetItem:
            let item = NSCustomTouchBarItem(identifier: identifier)
            let button = NSSegmentedControl(
                images: [NSImage(named: "Target")!],
                trackingMode: .selectAny,
                target: self,
                action: #selector(touchBarPointerAppearanceTargetPressed(_:)))
            item.view = button
            return item
            
        case .pointerAppearanceTargetColorItem:
            let item = NSCustomTouchBarItem(identifier: identifier)
            let button = NSSegmentedControl(
                images: [NSImage(named: "TargetColor")!],
                trackingMode: .selectAny,
                target: self,
                action: #selector(touchBarPointerAppearanceTargetColorPressed(_:)))
            item.view = button
            return item
            
        default:
            return nil
        }
    }
    
    
    @objc func touchBarPointerAppearanceCursorPressed(_ sender: NSSegmentedControl) {
        DisplayController.setPointerAppearance(.cursor, sender: self)
    }
    
    
    @objc func touchBarPointerAppearanceDotPressed(_ sender: NSSegmentedControl) {
        DisplayController.setPointerAppearance(.dot, sender: self)
    }
    
    @objc func touchBarPointerAppearanceCirclePressed(_ sender: NSSegmentedControl) {
        DisplayController.setPointerAppearance(.circle, sender: self)
    }
    
    @objc func touchBarPointerAppearanceTargetPressed(_ sender: NSSegmentedControl) {
        DisplayController.setPointerAppearance(.target, sender: self)
    }
    
    @objc func touchBarPointerAppearanceTargetColorPressed(_ sender: NSSegmentedControl) {
        DisplayController.setPointerAppearance(.targetColor, sender: self)
    }
    
    
    
    /**
     Selects/Deselect a button (in shape of an `NSSegmentedControl` with a single element) based on the condition.
     
     **NOTE**: `NSSegmentedControl` should only have one button.
    */
    private func setSelected(button: NSSegmentedControl, _ condition: Bool) {
        if condition {
            button.setSelected(true, forSegment: 0)
        } else {
            button.selectedSegment = -1
        }
    }
    
}
