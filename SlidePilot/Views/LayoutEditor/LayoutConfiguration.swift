//
//  LayoutConfiguration.swift
//  SlidePilot
//
//  Created by Pascal Braband on 09.11.21.
//  Copyright © 2021 Pascal Braband. All rights reserved.
//

import Cocoa

enum SlideType: String {
    case current, next, notes
}

extension NSPasteboard.PasteboardType {
    static let slideType = NSPasteboard.PasteboardType("de.pascalbraband.SlidePilot.pasteboardType.slideType")
}

struct LayoutType {
    enum Arrangement {
        case single, double, tripleRight, tripleLeft
    }
    
    private(set) var slideCount: Int
    private(set) var arrangement: Arrangement
    
    static let single = LayoutType(slideCount: 1, arrangement: .single)
    static let double = LayoutType(slideCount: 2, arrangement: .double)
    static let tripleRight = LayoutType(slideCount: 3, arrangement: .tripleRight)
    static let tripleLeft = LayoutType(slideCount: 3, arrangement: .tripleLeft)
}

struct LayoutConfiguration {
    var type: LayoutType
    private (set) var slides: [SlideType] = [.current, .next, .notes]
    
    mutating func moveSlide(type: SlideType, to targetIndex: Int) {
        if let originIndex = slides.firstIndex(of: type) {
            slides.swapAt(originIndex, targetIndex)
        }
    }
}
