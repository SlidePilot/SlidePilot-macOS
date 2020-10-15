//
//  PointerEditorViewController.swift
//  SlidePilot
//
//  Created by Pascal Braband on 15.10.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class PointerEditorViewController: NSViewController {

    @IBOutlet weak var stackView: NSStackView!
    
    @IBOutlet weak var shapeSelectionBox: NSPopUpButton!
    @IBOutlet weak var sizeSlider: NSSlider!
    @IBOutlet weak var thicknessSlider: NSSlider!
    @IBOutlet weak var colorPicker: NSColorWell!
    @IBOutlet weak var borderWidthSlider: NSSlider!
    @IBOutlet weak var borderColorPicker: NSColorWell!
    @IBOutlet weak var shadowToggle: NSButton!
    @IBOutlet weak var shadowWidthSlider: NSSlider!
    
    @IBOutlet weak var pointerViewContainer: NSView!
    var pointerView: PointerCCView!
    
    
    // Data
    let shapeMap: [(PointerCCView.Shape, String)] = [
        (.target, NSLocalizedString("Target Shape", comment: "Name for target shape in pointer editor.")),
        (.dot, NSLocalizedString("Dot Shape", comment: "Name for dot shape in pointer editor.")),
        (.circle, NSLocalizedString("Circle Shape", comment: "Name for circle shape in pointer editor.")),
        (.plus, NSLocalizedString("Plus Shape", comment: "Name for plus shape in pointer editor.")),
        (.cross, NSLocalizedString("Cross Shape", comment: "Name for cross shape in pointer editor.")),
        (.square, NSLocalizedString("Square Shape", comment: "Name for square shape in pointer editor."))]
    var shapeMapShapes: [PointerCCView.Shape]!
    var shapeMapStrings: [String]!
    
    
    // MARK: - Editor Configuration
    struct EditorConfiguration {
        var showSize: Bool = true
        var showThickness: Bool = true
        var showColor: Bool = true
        var showBorder: Bool = true
        var showBorderColor: Bool = true
        var showShadowWidth: Bool = true
        
        var minSize: Double?
        var maxSize: Double?
        var defaultSize: Double?
        
        var minThickness: Double?
        var maxThickness: Double?
        var defaultThickness: Double?
        
        var minBorder: Double?
        var maxBorder: Double?
        var defaultBorder: Double?
        
        var minShadow: Double?
        var maxShadow: Double?
        var defaultShadow: Double?
    }
    
    let editorConfigurations: [PointerCCView.Shape: EditorConfiguration] = [
        .target: EditorConfiguration(minSize: 35, maxSize: 150, defaultSize: 44, minThickness: 2, maxThickness: 50, defaultThickness: 3, minBorder: 0, maxBorder: 50, defaultBorder: 0, minShadow: 0, maxShadow: 50, defaultShadow: 0),
        .dot: EditorConfiguration(showThickness: false, minSize: 5, maxSize: 100, defaultSize: 10, minBorder: 0, maxBorder: 50, defaultBorder: 0, minShadow: 0, maxShadow: 50, defaultShadow: 0),
        .circle: EditorConfiguration(minSize: 5, maxSize: 100, defaultSize: 20, minThickness: 2, maxThickness: 50, defaultThickness: 3, minBorder: 0, maxBorder: 50, defaultBorder: 0, minShadow: 0, maxShadow: 50, defaultShadow: 0),
        .plus: EditorConfiguration(minSize: 5, maxSize: 100, defaultSize: 20, minThickness: 2, maxThickness: 50, defaultThickness: 3, minBorder: 0, maxBorder: 50, defaultBorder: 0, minShadow: 0, maxShadow: 50, defaultShadow: 0),
        .cross: EditorConfiguration(minSize: 5, maxSize: 100, defaultSize: 20, minThickness: 2, maxThickness: 50, defaultThickness: 3, minBorder: 0, maxBorder: 50, defaultBorder: 0, minShadow: 0, maxShadow: 50, defaultShadow: 0),
        .square: EditorConfiguration(showThickness: false, minSize: 5, maxSize: 100, defaultSize: 10, minBorder: 0, maxBorder: 50, defaultBorder: 0, minShadow: 0, maxShadow: 50, defaultShadow: 0)]
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup convenience properties
        shapeMapShapes = shapeMap.map({ $0.0 })
        shapeMapStrings = shapeMap.map({ $0.1 })
        
        stackView.setHuggingPriority(.windowSizeStayPut, for: .horizontal)
        
        // Set default values
        shapeSelectionBox.removeAllItems()
        shapeSelectionBox.addItems(withTitles: shapeMapStrings)
        colorPicker.color = .black
        borderColorPicker.color = .red
        
        // Setup pointer (preview)
        pointerView = PointerCCView(frame: NSRect(x: 0, y: 0, width: 10.0, height: 10.0))
        pointerViewContainer.addSubview(pointerView)
        pointerViewContainer.wantsLayer = true
        pointerViewContainer.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.2).cgColor
        pointerViewContainer.layer?.cornerRadius = 10.0
        
        pointerView.postsFrameChangedNotifications = true
        NotificationCenter.default.addObserver(self, selector: #selector(didChangePointerFrame), name: NSView.frameDidChangeNotification, object: nil)
        
        // Setup default configuration
        setup(editorConfiguration: editorConfigurations[.target]!)
    }
    
    
    @objc func didChangePointerFrame() {
        // Center pointer view in preview container
        pointerView.frame.origin = CGPoint(x: (pointerViewContainer.frame.width-pointerView.frame.width)/2,
                                           y: (pointerViewContainer.frame.height-pointerView.frame.height)/2)
    }
    
    
    func setup(editorConfiguration conf: EditorConfiguration) {
        sizeSlider.isEnabled = conf.showSize
        thicknessSlider.isEnabled = conf.showThickness
        colorPicker.isEnabled = conf.showColor
        borderWidthSlider.isEnabled = conf.showBorder
        borderColorPicker.isEnabled = conf.showBorderColor
        shadowWidthSlider.isEnabled = conf.showShadowWidth
        
        sizeSlider.minValue = conf.minSize ?? 0
        sizeSlider.maxValue = conf.maxSize ?? 1
        thicknessSlider.minValue = conf.minThickness ?? 0
        thicknessSlider.maxValue = conf.maxThickness ?? 1
        borderWidthSlider.minValue = conf.minBorder ?? 0
        borderWidthSlider.maxValue = conf.maxBorder ?? 1
        shadowWidthSlider.minValue = conf.minShadow ?? 0
        shadowWidthSlider.maxValue = conf.maxShadow ?? 0
        
        sizeSlider.floatValue = Float(conf.defaultSize ?? 0)
        thicknessSlider.floatValue = Float(conf.defaultThickness ?? 0)
        borderWidthSlider.floatValue = Float(conf.defaultBorder ?? 0)
        shadowWidthSlider.floatValue = Float(conf.defaultShadow ?? 0)
        
        // Update pointer preview with default values
        updatePointerView()
    }
    
    
    func updatePointerView() {
        pointerView.shape = shapeMapShapes[shapeSelectionBox.indexOfSelectedItem]
        pointerView.size = CGFloat(sizeSlider.floatValue)
        pointerView.thickness = CGFloat(thicknessSlider.floatValue)
        pointerView.color = colorPicker.color
        pointerView.borderWidth = CGFloat(borderWidthSlider.floatValue)
        pointerView.borderColor = borderColorPicker.color
        pointerView.shadowWidth = CGFloat(shadowWidthSlider.floatValue)
    }
    
    
    @IBAction func shapeSelected(_ sender: NSPopUpButton) {
        let selectedShape = shapeMapShapes[sender.indexOfSelectedItem]
        pointerView.shape = selectedShape
        guard let configuration = editorConfigurations[selectedShape] else { return }
        setup(editorConfiguration: configuration)
    }
    
    
    @IBAction func sizeSliderChanged(_ sender: NSSlider) {
        pointerView.size = CGFloat(sender.floatValue)
    }
    
    
    @IBAction func thicknessSliderChanged(_ sender: NSSlider) {
        pointerView.thickness = CGFloat(sender.floatValue)
    }
    
    
    @IBAction func colorChanged(_ sender: NSColorWell) {
        pointerView.color = sender.color
    }
    
    
    @IBAction func borderSliderChanged(_ sender: NSSlider) {
        pointerView.borderWidth = CGFloat(sender.floatValue)
    }
    
    
    @IBAction func borderColorChanged(_ sender: NSColorWell) {
        pointerView.borderColor = sender.color
    }
    
    
    @IBAction func shadowSliderChanged(_ sender: NSSlider) {
        pointerView.shadowWidth = CGFloat(sender.floatValue)
    }
}
