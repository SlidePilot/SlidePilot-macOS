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

struct LayoutType: Equatable {
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
    
    // Stores the previous arrangement type of triple arrangements
    private var previousTriple: LayoutType?
    
    // Stores the previous position of a slide. Should be stored only for the previously hidden slide.
    private var previousPosition: [SlideType: Int] = [:]
    
    
    init(type: LayoutType) {
        self.type = type
    }
    
    
    /**
     Moves the slide with the specified type to a target index.
     
     - parameters:
        - type: The `SlideType` to move.
        - targetIndex: The index, where the slide should be moved.
        - swap: If `swap` is `true`, the position's of the given slide and the one at target position are swapped. If `swap` is `false`, the given slide is extracted from it's current position and inserted at the new position. The other element then get shifted and the order amoung them is kept.
     */
    mutating func moveSlide(_ type: SlideType, to targetIndex: Int, swap: Bool = true) {
        if let originIndex = slides.firstIndex(of: type) {
            if swap {
                slides.swapAt(originIndex, targetIndex)
            } else {
                slides.insert(slides.remove(at: originIndex), at: targetIndex)
            }
        }
    }
    
    
    /**
     Hides the given slide.
     
     - parameters:
        - type: The `SlideType` to hide.
     */
    mutating func hideSlide(slide: SlideType) {
        // Move slide with given type to end of slides array and change arrangement to display one slide less
        if let originIndex = slides.firstIndex(of: slide) {
            // Preserve position of given slide
            previousPosition = [slide: originIndex]
            
            switch self.type {
            case .tripleLeft, .tripleRight:
                previousTriple = self.type
                self.type = .double
                slides.moveToEnd(from: originIndex)
                
            case .double:
                self.type = .single
                slides.moveToEnd(from: originIndex)
                
            case .single:
                // Don't hide slide, if in single mode an current slide is already presented
                // Otherwise show current slide
                if self.slides.first != .current {
                    // Move given slide to the end of slides and show current slide
                    slides.moveToEnd(from: originIndex)
                    moveSlide(.current, to: 0)
                }
                
            default:
                break
            }
        }
    }
    
    
    /**
     Shows the given slide.
     
     - parameters:
        - type: The `SlideType` to show.
     */
    mutating func showSlide(slide: SlideType) {
        // Take last slide and increase arrangement to display one more slide
        switch self.type {
        case .single:
            self.type = .double
            // Move slide to previous position if possible
            if let previousPosition = previousPosition[slide],
               previousPosition <= 1 {
                moveSlide(slide, to: previousPosition, swap: false)
            }
            // Otherwise move to the end
            else {
                moveSlide(slide, to: 1)
            }
            
        case .double:
            self.type = previousTriple ?? .tripleLeft
            // Move slide to previous position if possible
            if let previousPosition = previousPosition[slide],
               previousPosition <= 2 {
                moveSlide(slide, to: previousPosition, swap: false)
            }
            // Otherwise move to the end
            else {
                moveSlide(slide, to: 2)
            }
            
        default:
            // Nothing happens in the case of .tripleLeft and .tripleRight, because all slides are already shown
            break
        }
    }
}
