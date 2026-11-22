//
//  PDFPageView.swift
//  SlidePilot
//
//  Created by Pascal Braband on 23.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa
import PDFKit
import AVKit
import AVFoundation


class PDFPageView: NSImageView {
    
    var players = [AVPlayer]()
    var playerViews = [ConnectedPlayer]()
    var areVideoPlayerControlsEnabled: Bool = true
    var connectToCurrentPlayer: Bool = false
    
    
    enum DisplayMode {
        case full, leftHalf, rightHalf, topHalf, bottomHalf
        
        static func displayModeForNotes(with position: NotesPosition) -> DisplayMode {
            return position.displayModeForNotes()
        }
        
        static func displayModeForPresentation(with position: NotesPosition) -> DisplayMode {
            return position.displayModeForPresentation()
        }
        
        /**
         Returns correct bounds for `DisplayMode`.
         */
        func getBounds(for page: PDFPage) -> CGRect {
            let rotation = page.rotation
            let isRotatedClock = rotation == 90
            let isRotatedCounterClock = rotation == 270
            let isFlipped = rotation == 180
            switch self {
            case .full:
                return page.bounds(for: .mediaBox)
            case .leftHalf:
                if isRotatedCounterClock {
                    return CGRect(x: 0, y: page.bounds(for: .mediaBox).height/2, width: page.bounds(for: .mediaBox).width, height: page.bounds(for: .mediaBox).height/2)
                } else if isRotatedClock {
                    return CGRect(x: 0, y: 0, width: page.bounds(for: .mediaBox).width, height: page.bounds(for: .mediaBox).height/2)
                } else if isFlipped {
                    return CGRect(x: page.bounds(for: .mediaBox).width/2, y: 0, width: page.bounds(for: .mediaBox).width/2, height: page.bounds(for: .mediaBox).height)
                } else {
                    return CGRect(x: 0, y: 0, width: page.bounds(for: .mediaBox).width/2, height: page.bounds(for: .mediaBox).height)
                }
            case .rightHalf:
                if isRotatedCounterClock {
                    return CGRect(x: 0, y: 0, width: page.bounds(for: .mediaBox).width, height: page.bounds(for: .mediaBox).height/2)
                } else if isRotatedClock {
                    return CGRect(x: 0, y: page.bounds(for: .mediaBox).height/2, width: page.bounds(for: .mediaBox).width, height: page.bounds(for: .mediaBox).height/2)
                } else if isFlipped {
                    return CGRect(x: 0, y: 0, width: page.bounds(for: .mediaBox).width/2, height: page.bounds(for: .mediaBox).height)
                } else {
                    return CGRect(x: page.bounds(for: .mediaBox).width/2, y: 0, width: page.bounds(for: .mediaBox).width/2, height: page.bounds(for: .mediaBox).height)
                }
            case .topHalf:
                if isRotatedCounterClock {
                    return CGRect(x: page.bounds(for: .mediaBox).width/2, y: 0, width: page.bounds(for: .mediaBox).width/2, height: page.bounds(for: .mediaBox).height)
                } else if isRotatedClock {
                    return CGRect(x: 0, y: 0, width: page.bounds(for: .mediaBox).width/2, height: page.bounds(for: .mediaBox).height)
                } else if isFlipped {
                    return CGRect(x: 0, y: 0, width: page.bounds(for: .mediaBox).width, height: page.bounds(for: .mediaBox).height/2)
                } else {
                    return CGRect(x: 0, y: page.bounds(for: .mediaBox).height/2, width: page.bounds(for: .mediaBox).width, height: page.bounds(for: .mediaBox).height/2)
                }
            case .bottomHalf:
                if isRotatedCounterClock {
                    return CGRect(x: 0, y: 0, width: page.bounds(for: .mediaBox).width/2, height: page.bounds(for: .mediaBox).height)
                } else if isRotatedClock {
                    return CGRect(x: page.bounds(for: .mediaBox).width/2, y: 0, width: page.bounds(for: .mediaBox).width/2, height: page.bounds(for: .mediaBox).height)
                } else if isFlipped {
                    return CGRect(x: 0, y: page.bounds(for: .mediaBox).height/2, width: page.bounds(for: .mediaBox).width, height: page.bounds(for: .mediaBox).height/2)
                } else {
                    return CGRect(x: 0, y: 0, width: page.bounds(for: .mediaBox).width, height: page.bounds(for: .mediaBox).height/2)
                }
            }
        }
    }
    
    
    enum NotesPosition {
        case none, right, left, bottom, top
        
        func displayModeForNotes() -> DisplayMode {
            switch self {
            case .none:
                return .full
            case .right:
                return .rightHalf
            case .left:
                return .leftHalf
            case .bottom:
                return .bottomHalf
            case .top:
                return .topHalf
            }
        }
        
        func displayModeForPresentation() -> DisplayMode {
            switch self {
            case .none:
                return .full
            case .right:
                return .leftHalf
            case .left:
                return .rightHalf
            case .bottom:
                return .topHalf
            case .top:
                return .bottomHalf
            }
        }
    }
    
    
    private(set) var pdfDocument: PDFDocument?
    private(set) var displayMode: DisplayMode = .full
    private(set) var currentPage: Int = 0
    
    var areLinksEnabled: Bool = true {
        didSet {
            self.window?.invalidateCursorRects(for: self)
        }
    }
    
    /** Enabling this property will automatically set a height constraint, relative to the width constraint using the current images aspect ratio. */
    var isAutoAspectRatioConstraintEnabled = false
    var aspectRatioConstraint: NSLayoutConstraint?
    
    override var image: NSImage? {
        didSet {
            if isAutoAspectRatioConstraintEnabled {
                updateAspectRatio()
            }
        }
    }
    
    
    public func setDocument(_ document: PDFDocument?, mode displayMode: DisplayMode = .full, at currentPage: Int = 0) {
        self.pdfDocument = document
        self.displayMode = displayMode
        self.currentPage = currentPage
        RenderCache.shared.document = document
        reload()
    }
    
    
    public func setDisplayMode(_ displayMode: DisplayMode) {
        self.displayMode = displayMode
        reload()
    }
    
    
    public func setCurrentPage(_ currentPage: Int) {
        self.currentPage = currentPage
        reload()
    }
    
    
    public func pageForward() {
        guard currentPage + 1 < (pdfDocument?.pageCount ?? -1) else { return }
        currentPage = currentPage + 1
        reload()
    }
    
    
    public func pageBackward() {
        guard currentPage - 1 >= 0 else { return }
        currentPage = currentPage - 1
        reload()
    }
    
    
    private func reload() {
        // Get current page
        guard pdfDocument != nil else { removeMovies(); image = nil; return }
        guard currentPage >= 0, currentPage < (pdfDocument?.pageCount ?? -1) else { removeMovies(); image = nil; return }
        
        // Create NSImage from page
        guard let pdfImage = RenderCache.shared.getPage(at: currentPage, for: pdfDocument!, mode: self.displayMode, priority: .fast) else { return }
        
        // Display image
        crossfadeIfNeeded()
        self.imageScaling = .scaleProportionallyUpOrDown
        self.image = pdfImage
        
        // Update cursor rects
        self.window?.invalidateCursorRects(for: self)
        
        // Show videos
        embedVideo()
    }
    
    
    private var movieBounds = [CGRect]()
    private var movieGeneration = 0

    private func removeMovies() {
        movieGeneration += 1
        // A connected audience view must not pause the presenter's shared player.
        if !connectToCurrentPlayer {
            players.forEach { $0.pause() }
            if ConnectedPlayer.sharedPlayers?.contains(where: { shared in
                players.contains(where: { $0 === shared })
            }) == true {
                ConnectedPlayer.sharedPlayers = []
            }
        }
        let retiredPlayers = players
        let retiredViews = playerViews
        playerViews.forEach {
            if let responder = window?.firstResponder as? NSView,
               responder === $0 || responder.isDescendant(of: $0) {
                window?.makeFirstResponder(window)
            }
            $0.removeFromSuperview()
        }
        // Let the page-change notification finish before AVKit tears down its
        // media pipeline. Retain both views and players until the next turn.
        DispatchQueue.main.async {
            withExtendedLifetime(retiredPlayers) {}
            withExtendedLifetime(retiredViews) {}
        }
        players.removeAll()
        playerViews.removeAll()
        movieBounds.removeAll()
    }

    private func embedVideo() {
        removeMovies()
        // Previews remain PDF posters; only the current slide gets live players.
        guard currentPage == PageController.currentPage,
              let document = pdfDocument else { return }
        let generation = movieGeneration
        DispatchQueue.main.async { [weak self, weak document] in
            guard let self = self, let document = document,
                  self.movieGeneration == generation,
                  self.pdfDocument === document,
                  self.currentPage == PageController.currentPage else { return }
            self.installMovies()
        }
    }

    private func installMovies() {
        guard let page = pdfDocument?.page(at: currentPage) else { return }
        let visibleBounds = displayMode.getBounds(for: page)
        for movie in page.movieResources() {
            guard visibleBounds.intersects(movie.bounds),
                  let url = PDFMovieFiles.shared.url(for: movie.file, document: pdfDocument) else { continue }
            let player = AVPlayer(url: url)
            let playerView = ConnectedPlayer()
            playerView.player = player
            playerView.areControlsEnabled = areVideoPlayerControlsEnabled
            addSubview(playerView, positioned: .below, relativeTo: coverView)
            playerView.connectToSharedPlayer = connectToCurrentPlayer
            players.append(player)
            playerViews.append(playerView)
            movieBounds.append(movie.bounds)
        }
        layoutMovies()
        if currentPage == PageController.currentPage,
           !connectToCurrentPlayer,
           DisplayController.notesPosition.displayModeForPresentation() == displayMode {
            ConnectedPlayer.sharedPlayers = players
        }
    }

    override func layout() {
        super.layout()
        layoutMovies()
    }

    private func layoutMovies() {
        guard let page = pdfDocument?.page(at: currentPage) else { return }
        let pageBounds = displayMode.getBounds(for: page)
        let imageFrame = imageRect()
        let rotation = (page.rotation % 360 + 360) % 360
        func rotated(_ point: CGPoint) -> CGPoint {
            let x = (point.x - pageBounds.minX) / pageBounds.width
            let y = (point.y - pageBounds.minY) / pageBounds.height
            switch rotation {
            case 90: return CGPoint(x: y, y: 1 - x)
            case 180: return CGPoint(x: 1 - x, y: 1 - y)
            case 270: return CGPoint(x: 1 - y, y: x)
            default: return CGPoint(x: x, y: y)
            }
        }
        for (view, rect) in zip(playerViews, movieBounds) {
            let first = rotated(rect.origin)
            let last = rotated(CGPoint(x: rect.maxX, y: rect.maxY))
            view.frame = CGRect(x: imageFrame.minX + min(first.x, last.x) * imageFrame.width,
                                y: imageFrame.minY + min(first.y, last.y) * imageFrame.height,
                                width: abs(last.x - first.x) * imageFrame.width,
                                height: abs(last.y - first.y) * imageFrame.height)
        }
    }

    private let crossfadeDuration: CFTimeInterval = 0.6
    private let crossfadeAnimationKey: String = "crossfade"
    /** Setting this value to true will add a crossfade when changing the views image. */
    var crossfadeEnabled: Bool = false
    
    func crossfadeIfNeeded() {
        if crossfadeEnabled {
            let crossfadeAnimation = CATransition()
            crossfadeAnimation.duration = crossfadeDuration
            crossfadeAnimation.type = .fade
            crossfadeAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            self.layer?.add(crossfadeAnimation, forKey: crossfadeAnimationKey)
        }
    }
    
    
    
    
    private func updateAspectRatio() {
        if aspectRatioConstraint != nil {
            self.removeConstraint(aspectRatioConstraint!)
        }
        
        // Add aspect ratio constraint based on the current images size
        guard let imageSize = image?.size else { return }
        let aspectRatio = imageSize.height / imageSize.width
        aspectRatioConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: self, attribute: .width, multiplier: aspectRatio, constant: 0.0)
        self.addConstraint(aspectRatioConstraint!)

    }
    
    
    override func resetCursorRects() {
        super.resetCursorRects()
        
        // Check if links are enabled
        if areLinksEnabled {
            // Add cursor rects for annotation
            addAnnotationCursorRects()
        }
    }
    
    
    /** Adds cursor rect for where clickable annotations are. */
    private func addAnnotationCursorRects() {
        // Extract annotations
        guard let page = pdfDocument?.page(at: currentPage) else { return }
        
        // Add cursor rects for each annotation
        for annotation in page.annotations {
            // Only add cursor rect for link annotations
            guard annotation.type == "Link" else { continue }
            
            let annotationBounds = annotation.bounds
            let pageBounds = page.bounds(for: .cropBox)
            
            // Calculate relative bounds on PDF page
            let relativeBounds = NSRect(x: (annotationBounds.origin.x - pageBounds.origin.x) / pageBounds.width,
                                        y: (annotationBounds.origin.y - pageBounds.origin.y) / pageBounds.height,
                                        width: annotationBounds.width / pageBounds.width,
                                        height: annotationBounds.height / pageBounds.height)
            
            // Translate relative annotations bounds to PDF image bounds
            let imageFrame = imageRect()
            let annotationBoundsInImage = NSRect(x: relativeBounds.origin.x * imageFrame.width,
                                                 y: relativeBounds.origin.y * imageFrame.height,
                                                 width: relativeBounds.width * imageFrame.width,
                                                 height: relativeBounds.height * imageFrame.height)
            
            // Translate the annotation bounds position to self view frame
            let annotationBoundsInView = NSRect(x: annotationBoundsInImage.origin.x + imageFrame.origin.x,
                                                y: annotationBoundsInImage.origin.y + imageFrame.origin.y,
                                                width: annotationBoundsInImage.width,
                                                height: annotationBoundsInImage.height)
            
            // Only continue, when annotation is in image frame
            guard imageFrame.intersects(annotationBoundsInView) else { continue }
            
            addCursorRect(annotationBoundsInView, cursor: .pointingHand)
        }
    }
    
    
    override func mouseDown(with event: NSEvent) {
        // Only continue if links are enabled
        guard areLinksEnabled else { super.mouseDown(with: event); return }
        
        // Calculate the point in relativity to this views origin
        guard let pointInView = self.window?.contentView?.convert(event.locationInWindow, to: self) else { super.mouseDown(with: event); return }
        
        // Only continue if click is inside of imageFrame
        let imageFrame = imageRect()
        guard imageFrame.contains(pointInView) else { super.mouseDown(with: event); return }
        
        // Calculate the absolute point on the displayed PDF image
        let pointInImage = NSPoint(x: pointInView.x - imageFrame.origin.x, y: pointInView.y - imageFrame.origin.y)
        
        // Calculate the relative point on the displayed PDF image (relative to its size)
        let relativePointInImage = NSPoint(x: pointInImage.x / imageFrame.width , y: pointInImage.y / imageFrame.height)
        
        // Calculate click point relative to PDF page bounds
        guard let page = pdfDocument?.page(at: currentPage) else { super.mouseDown(with: event); return }
        let pageBounds = page.bounds(for: .cropBox)
        let pointOnPage = NSPoint(x: relativePointInImage.x * pageBounds.width + pageBounds.origin.x,
                                  y: relativePointInImage.y * pageBounds.height + pageBounds.origin.y)
        // Add pageBounds.origin.x and y to fix when only top half or right half is displayed
        // That means that the origin for the crop box is not at (0,0)
        
        // Get annotation for click position
        guard let annotation = pdfDocument?.page(at: currentPage)?.annotation(at: pointOnPage) else { super.mouseDown(with: event); return }
        
        
        // Handle clicking on annotation
        
        // Go to document page
        if let goToAction = annotation.action as? PDFActionGoTo {
            guard let destPage = goToAction.destination.page else { super.mouseDown(with: event); return }
            guard let destPageIndex = pdfDocument?.index(for: destPage) else { super.mouseDown(with: event); return }
            PageController.selectPage(at: destPageIndex, sender: self)
        }
        
        // Open web page
        else if let urlAction = annotation.action as? PDFActionURL {
            guard let url = urlAction.url else { return }
            // Open url in browser
            if #available(OSX 10.15, *) {
                let openConfig = NSWorkspace.OpenConfiguration()
                openConfig.addsToRecentItems = true
                NSWorkspace.shared.open(url, configuration: openConfig, completionHandler: nil)
            } else {
                NSWorkspace.shared.open(url)
            }
        }
    }
    
    
    private func getRectFor(mode: DisplayMode, pdfPage: PDFPage) -> CGRect {
        switch mode {
        case .full:
            return pdfPage.bounds(for: .mediaBox)
        case .leftHalf:
            return CGRect(x: 0, y: 0, width: pdfPage.bounds(for: .mediaBox).width/2, height: pdfPage.bounds(for: .mediaBox).height)
        case .rightHalf:
            return CGRect(x: pdfPage.bounds(for: .mediaBox).width/2, y: 0, width: pdfPage.bounds(for: .mediaBox).width/2, height: pdfPage.bounds(for: .mediaBox).height)
        case .topHalf:
            return CGRect(x: 0, y: pdfPage.bounds(for: .mediaBox).height/2, width: pdfPage.bounds(for: .mediaBox).width, height: pdfPage.bounds(for: .mediaBox).height/2)
        case .bottomHalf:
            return CGRect(x: 0, y: 0, width: pdfPage.bounds(for: .mediaBox).width, height: pdfPage.bounds(for: .mediaBox).height/2)
        }
    }
    
    
    
    
    // MARK: - Alternative Display and Cover
    
    public func displayBlank() {
        removeMovies()
        self.image = NSColor.black.image(of: (pdfDocument?.page(at: 0)?.bounds(for: .cropBox).size ?? NSSize(width: 1.0, height: 1.0)))
    }
    
    
    private var coverView: NSView?
    
    private func addCover() {
        uncover()
        self.coverView = NSView(frame: .zero)
        self.coverView?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(coverView!)
        self.addConstraints([NSLayoutConstraint(item: coverView!, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: coverView!, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: coverView!, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: coverView!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0)])
    }
    
    
    public var isCoveredWhite: Bool = false
    
    /** Covers the view with a white screen */
    public func coverWhite() {
        addCover()
        self.coverView?.wantsLayer = true
        self.coverView?.layer?.backgroundColor = NSColor.white.cgColor
        isCoveredWhite = true
    }
    
    
    public var isCoveredBlack: Bool = false
    
    /** Covers the view with a black screen */
    public func coverBlack() {
        addCover()
        self.coverView?.wantsLayer = true
        self.coverView?.layer?.backgroundColor = NSColor.black.cgColor
        isCoveredBlack = true
    }
    
    
    public func uncover() {
        coverView?.removeFromSuperview()
        coverView = nil
        isCoveredWhite = false
        isCoveredBlack = false
    }
}

