//
//  RemoteController.swift
//  SlidePilot
//
//  Created by Pascal Braband on 08.10.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa
import MultipeerConnectivity

class RemoteController {
    
    static let shared = RemoteController()
    
    public var service = RemoteService()
    
    
    init() {
        service.delegate = self
        
        // Subscribe to page changes
        PageController.subscribe(target: self, action: #selector(sendUpdates))
        DocumentController.subscribeDidOpenDocument(target: self, action: #selector(sendUpdates))
        DisplayController.subscribeNotesPosition(target: self, action: #selector(sendUpdates))
        DisplayController.subscribeDisplayCurtain(target: self, action: #selector(sendMetaUpdates))
        DocumentController.subscribeDidEditNotes(target: self, action: #selector(sendNotesUpdates))
    }
    
    
    /** This is a dummy method, which should be called on app start, to initialize the shared instance of RemoteController, which again initializes the RemoteService, which then starts searching for remote controllers. */
    func setup() { }
    
    
    /** Sends updates to the remote controller. */
    @objc func sendUpdates() {
        guard let document = DocumentController.document else { return }
        let pageIndex: Int = PageController.currentPage
        
        guard let currentSlide = RenderCache.shared.getPage(
                at: pageIndex,
                for: document,
                mode: DisplayController.notesPosition.displayModeForPresentation(),
                priority: .fast) else { return }
        
        guard let notesSlide = RenderCache.shared.getPage(
                at: pageIndex,
                for: document,
                mode: DisplayController.notesPosition.displayModeForNotes(),
                priority: .fast) else { return }
        
        // Special handling of next slide (send black slide when at the end of presentation)
        var nextSlide: NSImage!
        if pageIndex+1 < DocumentController.pageCount {
            guard let nextSlideImage = RenderCache.shared.getPage(
                    at: pageIndex+1,
                    for: document,
                    mode: DisplayController.notesPosition.displayModeForPresentation(),
                    priority: .fast) else { return }
            nextSlide = nextSlideImage
        } else {
            nextSlide = NSColor.black.image(of: (document.page(at: 0)?.bounds(for: .cropBox).size ?? NSSize(width: 1.0, height: 1.0)))
        }
        
        service.send(currentSlide: currentSlide)
        service.send(nextSlide: nextSlide)
        service.send(notesSlide: notesSlide)
        
        sendMetaUpdates()
        sendNotesUpdates()
    }
    
    
    @objc func sendMetaUpdates() {
        guard let document = DocumentController.document else { return }
        let metaInfo: [String: Any] = ["currentSlideNumber": PageController.currentPage+1,
                                       "slideCount": document.pageCount,
                                       "isBlackCurtainDisplayed": DisplayController.isBlackCurtainDisplayed,
                                       "isWhiteCurtainDisplayed": DisplayController.isWhiteCurtainDisplayed]
        service.send(meta: metaInfo)
    }
    
    
    @objc func sendNotesUpdates() {
        guard let notes = DocumentController.notesDocument else { return }
        service.send(notesText: notes.contents[PageController.currentPage])
    }
    
    
    
    
    // MARK: - Subscribe
    
    /** Subscribes a target to all `name` notifications sent by `RemoteController`. */
    public func subscribeRemotePeersChanged(target: Any, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: .remotePeersChanged, object: nil)
    }
    
    /** Subscribes a target to all `.remoteBrowsingFailed` notifications sent by `RemoteController`. */
    public func subscribeRemoteBrowsingFailed(target: Any, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: .remoteBrowsingFailed, object: nil)
    }
    
    /** Subscribes a target to all `.remoteDidSendVerification` notifications sent by `RemoteController`. */
    public func subscribeRemoteDidSendVerification(target: Any, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: .remoteDidSendVerification, object: nil)
    }
    
    /** Subscribes a target to all `.remoteShowNextSlide` notifications sent by `RemoteController`. */
    public func subscribeRemoteShowNextSlide(target: Any, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: .remoteShowNextSlide, object: nil)
    }
    
    /** Subscribes a target to all `.remoteShowPreviousSlide` notifications sent by `RemoteController`. */
    public func subscribeRemoteShowPreviousSlide(target: Any, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: .remoteShowPreviousSlide, object: nil)
    }
    
    /** Subscribes a target to all `.remoteShowBlackScreen` notifications sent by `RemoteController`. */
    public func subscribeRemoteShowBlackScreen(target: Any, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: .remoteShowBlackScreen, object: nil)
    }
    
    /** Subscribes a target to all `.remoteShowWhiteScreen` notifications sent by `RemoteController`. */
    public func subscribeRemoteShowWhiteScreen(target: Any, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: .remoteShowWhiteScreen, object: nil)
    }
    
    /** Subscribes a target to all `.remoteHideCurtain` notifications sent by `RemoteController`. */
    public func subscribeRemoteHideCurtain(target: Any, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: .remoteHideCurtain, object: nil)
    }
    
   
    
    /** Unsubscribes a target from all notifications sent by `RemoteController`. */
    public func unsubscribe(target: Any) {
        NotificationCenter.default.removeObserver(target, name: .remotePeersChanged, object: nil)
        NotificationCenter.default.removeObserver(target, name: .remoteBrowsingFailed, object: nil)
        NotificationCenter.default.removeObserver(target, name: .remoteDidSendVerification, object: nil)
        NotificationCenter.default.removeObserver(target, name: .remoteShowNextSlide, object: nil)
        NotificationCenter.default.removeObserver(target, name: .remoteShowPreviousSlide, object: nil)
        NotificationCenter.default.removeObserver(target, name: .remoteShowBlackScreen, object: nil)
        NotificationCenter.default.removeObserver(target, name: .remoteShowWhiteScreen, object: nil)
        NotificationCenter.default.removeObserver(target, name: .remoteHideCurtain, object: nil)
    }
}




extension RemoteController: RemoteServiceDelegate {
    func peersChanged() {
        // Send updates, if at least one peer is connected (this could be a new peer, which needs the current data)
        if service.peers.contains(where: { $0.state == .connected }) {
            sendUpdates()
        }
        NotificationCenter.default.post(name: .remotePeersChanged, object: nil)
    }
    
    func browsingFailed(_ error: Error) {
        NotificationCenter.default.post(name: .remoteBrowsingFailed, object: nil, userInfo: ["error": error])
    }
    
    func didSendVerfication(code: String, to peer: MCPeerID) {
        NotificationCenter.default.post(name: .remoteDidSendVerification, object: nil, userInfo: ["code": code, "peer": peer])
    }
    
    func shouldShowNextSlide() {
        PageController.nextPage(sender: self)
        NotificationCenter.default.post(name: .remoteShowNextSlide, object: nil)
    }
    
    func shouldShowPreviousSlide() {
        PageController.previousPage(sender: self)
        NotificationCenter.default.post(name: .remoteShowPreviousSlide, object: nil)
    }
    
    func shouldShowBlackScreen() {
        DisplayController.setDisplayCurtain(.black, sender: self)
        NotificationCenter.default.post(name: .remoteShowBlackScreen, object: nil)
    }
    
    func shouldShowWhiteScreen() {
        DisplayController.setDisplayCurtain(.white, sender: self)
        NotificationCenter.default.post(name: .remoteShowWhiteScreen, object: nil)
    }
    
    func shouldHideCutrain() {
        DisplayController.setDisplayCurtain(.none, sender: self)
        NotificationCenter.default.post(name: .remoteHideCurtain, object: nil)
    }
    
    func shouldMovePointer(to position: NSPoint) {
        if let presenterVC = (NSApp.delegate as? AppDelegate)?.presenterWindow?.contentViewController as? PresenterViewController {
            let relativePosition = CGPoint(x: (position.x + 1) / 2, y: (position.y + 1) / 2)
            presenterVC.pointerDelegate?.showPointer()
            presenterVC.pointerDelegate?.pointerMoved(to: relativePosition)
        }
    }
}




extension Notification.Name {
    static let remotePeersChanged = Notification.Name("remotePeersChanged")
    static let remoteBrowsingFailed = Notification.Name("remoteBrowsingFailed")
    static let remoteDidSendVerification = Notification.Name("remoteDidSendVerification")
    static let remoteShowNextSlide = Notification.Name("remoteShowNextSlide")
    static let remoteShowPreviousSlide = Notification.Name("remoteShowPreviousSlide")
    static let remoteShowBlackScreen = Notification.Name("remoteShowBlackScreen")
    static let remoteShowWhiteScreen = Notification.Name("remoteShowWhiteScreen")
    static let remoteHideCurtain = Notification.Name("remoteHideCurtain")
}
