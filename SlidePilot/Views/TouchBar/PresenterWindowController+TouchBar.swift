//
//  PresenterWindowController+TouchBar.swift
//  SlidePilot
//
//  Created by Pascal Braband on 28.04.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

@available(OSX 10.12.2, *)
extension PresenterWindowController: NSTouchBarDelegate {
    
    func setupTouchBar() {
        // Subscribe to display changes
        DisplayController.subscribeDisplayNotes(target: self, action: #selector(displayNotesDidChangeTouchBar(_:)))
        DisplayController.subscribeDisplayBlackCurtain(target: self, action: #selector(displayBlackCurtainDidChangeTouchBar(_:)))
        DisplayController.subscribeDisplayWhiteCurtain(target: self, action: #selector(displayWhiteCurtainDidChangeTouchBar(_:)))
        DisplayController.subscribeDisplayNavigator(target: self, action: #selector(displayNavigatorDidChangeTouchBar(_:)))
        DisplayController.subscribePreviewNextSlide(target: self, action: #selector(displayNextSlidePreviewDidChangeTouchBar(_:)))
        DisplayController.subscribeDisplayPointer(target: self, action: #selector(displayPointerDidChangeTouchBar(_:)))
        
        // Subscribe to canvas changes
        CanvasController.subscribeCanvasBackgroundChanged(target: self, action: #selector(canvasBackgroundDidChangeTouchBar(_:)))
        CanvasController.subscribeDrawingColorChanged(target: self, action: #selector(drawingColorDidChangeTouchBar(_:)))
    }
    
    
    override func makeTouchBar() -> NSTouchBar? {
        // Create TouchBar and assign delegate
        var touchBar = NSTouchBar()
        touchBar.delegate = self
        
        if DisplayController.areDrawingToolsDisplayed {
            setupDrawingTouchBar(&touchBar)
        } else {
            setupDefaultTouchBar(&touchBar)
        }
        
        return touchBar
    }
    
    
    func setupDefaultTouchBar(_ touchBar: inout NSTouchBar) {
        touchBar.defaultItemIdentifiers = [.blackCurtainItem, .whiteCurtainItem, .notesItem, .navigatorItem, .previewNextSlideItem, .fixedSpaceLarge, .pointerItem, .pointerAppearancePopover]
    }
    
    
    func setupDrawingTouchBar(_ touchBar: inout NSTouchBar) {
        touchBar.defaultItemIdentifiers = [.drawingColorItem, .eraserItem, .canvasItem, .fixedSpaceLarge, .closeItem]
    }
    
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier {
            
        case .blackCurtainItem:
            let item = NSCustomTouchBarItem(identifier: identifier)
            let button = NSSegmentedControl(
                images: [NSImage(named: "BlackCurtain")!],
                trackingMode: .selectAny,
                target: self,
                action: #selector(touchBarBlackCurtainPressed))
            setSelected(button: button, DisplayController.isBlackCurtainDisplayed)
            item.view = button
            item.customizationLabel = NSLocalizedString("BlackCurtainTBLabel", comment: "The customization label for black curtain Touch Bar item.")
            return item
            
        case .whiteCurtainItem:
            let item = NSCustomTouchBarItem(identifier: identifier)
            let button = NSSegmentedControl(
                images: [NSImage(named: "WhiteCurtain")!],
                trackingMode: .selectAny,
                target: self,
                action: #selector(touchBarWhiteCurtainPressed(_:)))
            setSelected(button: button, DisplayController.isWhiteCurtainDisplayed)
            item.view = button
            item.customizationLabel = NSLocalizedString("WhiteCurtainTBLabel", comment: "The customization label for white curtain Touch Bar item.")
            return item
            
        case .notesItem:
            let item = NSCustomTouchBarItem(identifier: identifier)
            let button = NSSegmentedControl(
                images: [NSImage(named: NSImage.touchBarTextListTemplateName)!],
                trackingMode: .selectAny,
                target: self,
                action: #selector(touchBarNotesPressed(_:)))
            setSelected(button: button, DisplayController.areNotesDisplayed)
            item.view = button
            item.customizationLabel = NSLocalizedString("NotesTBLabel", comment: "The customization label for notes Touch Bar item.")
            return item
            
        case .navigatorItem:
            let item = NSCustomTouchBarItem(identifier: identifier)
            let button = NSSegmentedControl(
                images: [NSImage(named: NSImage.touchBarOpenInBrowserTemplateName)!],
                trackingMode: .selectAny,
                target: self,
                action: #selector(touchBarNavigatorPressed(_:)))
            setSelected(button: button, DisplayController.isNavigatorDisplayed)
            item.view = button
            item.customizationLabel = NSLocalizedString("NavigatorTBLabel", comment: "The customization label for navigator Touch Bar item.")
            return item
            
        case .previewNextSlideItem:
        let item = NSCustomTouchBarItem(identifier: identifier)
        let button = NSSegmentedControl(
            images: [NSImage(named: "NextSlide")!],
            trackingMode: .selectAny,
            target: self,
            action: #selector(touchBarPreviewNextSlidePressed(_:)))
        setSelected(button: button, DisplayController.isNextSlidePreviewDisplayed)
        item.view = button
        item.customizationLabel = NSLocalizedString("PreviewNextSlideTBLabel", comment: "The customization label for preview next slide Touch Bar item.")
        return item
            
        case .pointerItem:
            // Setup show/hide pointer button
            let item = NSCustomTouchBarItem(identifier: .pointerItem)
            let button = NSSegmentedControl(
                images: [NSImage(named: "Cursor")!],
                trackingMode: .selectAny,
                target: self,
                action: #selector(touchBarPointerPressed(_:)))
            setSelected(button: button, DisplayController.isPointerDisplayed)
            item.view = button
            item.customizationLabel = NSLocalizedString("PointerTBLabel", comment: "The customization label for pointer Touch Bar item.")
            return item
            
        case .pointerAppearancePopover:
            // Setup appearance popover
            let appearancePopover = NSPopoverTouchBarItem(identifier: .pointerAppearancePopover)
            appearancePopover.showsCloseButton = true
            appearancePopover.collapsedRepresentationImage = NSImage(named: NSImage.touchBarQuickLookTemplateName)!
            let appearanceTouchBar = PointerAppearanceTouchBar()
            appearancePopover.pressAndHoldTouchBar = appearanceTouchBar
            appearancePopover.popoverTouchBar = appearanceTouchBar
            appearancePopover.customizationLabel = NSLocalizedString("PointerAppearanceTBLabel", comment: "The customization label for pointer appearance Touch Bar item.")
            
            return appearancePopover
            
        case .drawingColorItem:
            let colorPicker = NSColorPickerTouchBarItem(identifier: identifier)
            colorPicker.colorList = DrawingToolbar.availableColorList
            colorPicker.color = CanvasController.drawingColor
            colorPicker.target = self
            colorPicker.action = #selector(touchBarDrawingColorSelected(_:))
            return colorPicker
            
        case .eraserItem:
            let item = NSCustomTouchBarItem(identifier: identifier)
            let button = NSButton(
                image: NSImage(named: "EraserTB")!,
                target: self, action: #selector(touchBarEraserPressed(_:)))
            item.view = button
            return item
            
        case .canvasItem:
            let item = NSCustomTouchBarItem(identifier: identifier)
            let button = NSSegmentedControl(
                images: [NSImage(named: "CanvasTB")!],
                trackingMode: .selectAny,
                target: self,
                action: #selector(touchBarCanvasPressed(_:)))
            setSelected(button: button, !CanvasController.isCanvasBackgroundTransparent)
            item.view = button
            return item
            
        case .closeItem:
            let item = NSCustomTouchBarItem(identifier: identifier)
            let button = NSButton(
                image: NSImage(named: "CloseTB")!,
                target: self, action: #selector(touchBarCloseDrawingToolsPressed(_:)))
            item.view = button
            return item
            
        default:
            return nil
        }
    }
    
    
    @objc func touchBarBlackCurtainPressed(_ sender: NSSegmentedControl) {
        DisplayController.switchDisplayBlackCurtain(sender: sender)
    }
    
    
    @objc func touchBarWhiteCurtainPressed(_ sender: NSSegmentedControl) {
        DisplayController.switchDisplayWhiteCurtain(sender: sender)
    }
    
    
    @objc func touchBarNotesPressed(_ sender: NSSegmentedControl) {
        DisplayController.switchDisplayNotes(sender: sender)
    }
    
    
    @objc func touchBarNavigatorPressed(_ sender: NSSegmentedControl) {
        DisplayController.switchDisplayNavigator(sender: sender)
    }
    
    
    @objc func touchBarPreviewNextSlidePressed(_ sender: NSSegmentedControl) {
        DisplayController.switchDisplayNextSlidePreview(sender: sender)
    }
    
    
    @objc func touchBarPointerPressed(_ sender: NSSegmentedControl) {
        DisplayController.switchDisplayPointer(sender: sender)
    }
    
    
    @objc func touchBarDrawingColorSelected(_ sender: NSColorPickerTouchBarItem) {
        CanvasController.setDrawingColor(to: sender.color, sender: self)
    }
    
    
    @objc func touchBarEraserPressed(_ sender: NSButton) {
        CanvasController.clearCanvas(sender: sender)
    }
    
    
    @objc func touchBarCanvasPressed(_ sender: NSSegmentedControl) {
        CanvasController.switchTransparentCanvas(sender: sender)
    }
    
    
    @objc func touchBarCloseDrawingToolsPressed(_ sender: NSButton) {
        DisplayController.setDisplayDrawingTools(false, sender: sender)
    }
    
    
    
    // MARK: - Control Handlers
    
    @objc func displayNotesDidChangeTouchBar(_ notification: Notification) {
        // Set correct state for touch bar button
        guard let notesItem = self.touchBar?.item(forIdentifier: .notesItem) else { return }
        guard let notesButton = notesItem.view as? NSSegmentedControl else { return }
        
        setSelected(button: notesButton, DisplayController.areNotesDisplayed)
    }
    
    
    @objc func displayBlackCurtainDidChangeTouchBar(_ notification: Notification) {
        // Set correct state for touch bar button
        guard let blackCurtainItem = self.touchBar?.item(forIdentifier: .blackCurtainItem) else { return }
        guard let blackCurtainButton = blackCurtainItem.view as? NSSegmentedControl else { return }
        
        setSelected(button: blackCurtainButton, DisplayController.isBlackCurtainDisplayed)
    }
    
    
    @objc func displayWhiteCurtainDidChangeTouchBar(_ notification: Notification) {
        // Set correct state for touch bar button
        guard let whiteCurtainItem = self.touchBar?.item(forIdentifier: .whiteCurtainItem) else { return }
        guard let whiteCurtainButton = whiteCurtainItem.view as? NSSegmentedControl else { return }
        
        setSelected(button: whiteCurtainButton, DisplayController.isWhiteCurtainDisplayed)
    }
    
    
    @objc func displayNavigatorDidChangeTouchBar(_ notification: Notification) {
        // Set correct state for touch bar button
        guard let navigatorItem = self.touchBar?.item(forIdentifier: .navigatorItem) else { return }
        guard let navigatorButton = navigatorItem.view as? NSSegmentedControl else { return }
        
        setSelected(button: navigatorButton, DisplayController.isNavigatorDisplayed)
    }
    
    
    @objc func displayNextSlidePreviewDidChangeTouchBar(_ notification: Notification) {
        // Set correct state for touch bar button
        guard let previewNextSlideItem = self.touchBar?.item(forIdentifier: .previewNextSlideItem) else { return }
        guard let previewNextSlideButton = previewNextSlideItem.view as? NSSegmentedControl else { return }
        
        setSelected(button: previewNextSlideButton, DisplayController.isNextSlidePreviewDisplayed)
    }
    
    
    @objc func displayPointerDidChangeTouchBar(_ notification: Notification) {
        // Set correct state for touch bar button
        guard let pointerItem = self.touchBar?.item(forIdentifier: .pointerItem) else { return }
        guard let pointerButton = pointerItem.view as? NSSegmentedControl else { return }
        
        setSelected(button: pointerButton, DisplayController.isPointerDisplayed)
    }
    
    
    @objc func canvasBackgroundDidChangeTouchBar(_ notification: Notification) {
        guard let canvasItem = self.touchBar?.item(forIdentifier: .canvasItem) else { return }
        guard let canvasButton = canvasItem.view as? NSSegmentedControl else { return }
        
        setSelected(button: canvasButton, !CanvasController.isCanvasBackgroundTransparent)
    }
    
    
    @objc func drawingColorDidChangeTouchBar(_ notification: Notification) {
        guard let colorPicker = self.touchBar?.item(forIdentifier: .drawingColorItem) as? NSColorPickerTouchBarItem else { return }
        colorPicker.color = CanvasController.drawingColor
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
