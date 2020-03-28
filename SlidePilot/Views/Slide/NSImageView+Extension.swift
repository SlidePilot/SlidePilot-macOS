//
//  NSImageView+Extension.swift
//  SlidePilot
//
//  Created by Pascal Braband on 25.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

    extension NSImageView {

        /** Returns an `NSRect` of the drawn image in the view. */
        func imageRect() -> NSRect {
            // Find the content frame of the image without any borders first
            var contentFrame = self.bounds
            guard let imageSize = image?.size else { return .zero }
            let imageFrameStyle = self.imageFrameStyle

            if imageFrameStyle == .button || imageFrameStyle == .groove {
                contentFrame = NSInsetRect(self.bounds, 2, 2)
            } else if imageFrameStyle == .photo {
                contentFrame = NSRect(x: contentFrame.origin.x + 1, y: contentFrame.origin.x + 2, width: contentFrame.size.width - 3, height: contentFrame.size.height - 3)
            } else if imageFrameStyle == .grayBezel {
                contentFrame = NSInsetRect(self.bounds, 8, 8)
            }
            
            
            // Now find the right image size for the current imageScaling
            let imageScaling = self.imageScaling
            var drawingSize = imageSize

            // Proportionally scaling
            if imageScaling == .scaleProportionallyDown || imageScaling == .scaleProportionallyUpOrDown {
                var targetScaleSize = contentFrame.size
                if imageScaling == .scaleProportionallyDown {
                    if targetScaleSize.width > imageSize.width { targetScaleSize.width = imageSize.width }
                    if targetScaleSize.height > imageSize.height { targetScaleSize.height = imageSize.height }
                }

                let scaledSize = self.sizeByScalingProportianlly(toSize: targetScaleSize, fromSize: imageSize)
                drawingSize = NSSize(width: scaledSize.width, height: scaledSize.height)
            }
            
            // Axes independent scaling
            else if imageScaling == .scaleAxesIndependently {
                drawingSize = contentFrame.size
            }
            
            
            // Now get the image position inside the content frame (center is default) from the current imageAlignment
            let imageAlignment = self.imageAlignment
            var drawingPosition = NSPoint(x: contentFrame.origin.x + contentFrame.size.width / 2 - drawingSize.width / 2,
                                          y: contentFrame.origin.y + contentFrame.size.height / 2 - drawingSize.height / 2)
            
            // Top Alignments
            if imageAlignment == .alignTop || imageAlignment == .alignTopLeft || imageAlignment == .alignTopRight {
                drawingPosition.y = contentFrame.origin.y + contentFrame.size.height - drawingSize.height
                
                if imageAlignment == .alignTopLeft {
                    drawingPosition.x = contentFrame.origin.x
                } else if imageAlignment == .alignTopRight {
                    drawingPosition.x = contentFrame.origin.x + contentFrame.size.width - drawingSize.width
                }
            }
            
            // Bottom Alignments
            else if imageAlignment == .alignBottom || imageAlignment == .alignBottomLeft || imageAlignment == .alignBottomRight {
                drawingPosition.y = contentFrame.origin.y

                if imageAlignment == .alignBottomLeft {
                    drawingPosition.x = contentFrame.origin.x
                } else if imageAlignment == .alignBottomRight {
                    drawingPosition.x = contentFrame.origin.x + contentFrame.size.width - drawingSize.width
                }
            }
            
            // Left Alignment
            else if imageAlignment == .alignLeft {
                drawingPosition.x = contentFrame.origin.x
            }
            
            // Right Alginment
            else if imageAlignment == .alignRight {
                drawingPosition.x = contentFrame.origin.x + contentFrame.size.width - drawingSize.width
            }
            
            return NSRect(x: round(drawingPosition.x), y: round(drawingPosition.y), width: ceil(drawingSize.width), height: ceil(drawingSize.height))
        }

        
        func sizeByScalingProportianlly(toSize newSize: NSSize, fromSize oldSize: NSSize) -> NSSize {
            let widthHeightDivision = oldSize.width / oldSize.height
            let heightWidthDivision = oldSize.height / oldSize.width
            
            var scaledSize = NSSize.zero
            
            if oldSize.width > oldSize.height {
                if (widthHeightDivision * newSize.height) >= newSize.width {
                    scaledSize = NSSize(width: newSize.width, height: heightWidthDivision * newSize.width)
                } else {
                    scaledSize = NSSize(width: widthHeightDivision * newSize.height, height: newSize.height)
                }
            } else {
                if (heightWidthDivision * newSize.width) >= newSize.height {
                    scaledSize = NSSize(width: widthHeightDivision * newSize.height, height: newSize.height)
                } else {
                    scaledSize = NSSize(width: newSize.width, height: heightWidthDivision * newSize.width)
                }
            }
            
            return scaledSize
        }
    }
