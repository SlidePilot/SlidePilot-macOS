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
        PageController.subscribe(target: self, action: #selector(sendUpdates(_:)))
        DocumentController.subscribeDidOpenDocument(target: self, action: #selector(sendUpdates(_:)))
        DisplayController.subscribeNotesPosition(target: self, action: #selector(sendUpdates(_:)))
        
    }
    
    
    /** This is a dummy method, which should be called on app start, to initialize the shared instance of RemoteController, which again initializes the RemoteService, which then starts searching for remote controllers. */
    func setup() { }
    
    
    /** Sends updates to the remote controller. */
    @objc func sendUpdates(_ notification: Notification) {
        guard let document = DocumentController.document else { return }
        
        guard let currentSlide = RenderCache.shared.getPage(
                at: PageController.currentPage,
                for: document,
                mode: DisplayController.notesPosition.displayModeForPresentation(),
                priority: .fast) else { return }
        guard let nextSlide = RenderCache.shared.getPage(
                at: PageController.currentPage+1,
                for: document,
                mode: DisplayController.notesPosition.displayModeForPresentation(),
                priority: .fast) else { return }
        guard let notesSlide = RenderCache.shared.getPage(
                at: PageController.currentPage,
                for: document,
                mode: DisplayController.notesPosition.displayModeForNotes(),
                priority: .fast) else { return }
        
        service.send(currentSlide: currentSlide)
        service.send(nextSlide: nextSlide)
        service.send(notesSlide: notesSlide)
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
    
   
    
    /** Unsubscribes a target from all notifications sent by `RemoteController`. */
    public func unsubscribe(target: Any) {
        NotificationCenter.default.removeObserver(target, name: .remotePeersChanged, object: nil)
        NotificationCenter.default.removeObserver(target, name: .remoteBrowsingFailed, object: nil)
        NotificationCenter.default.removeObserver(target, name: .remoteDidSendVerification, object: nil)
        NotificationCenter.default.removeObserver(target, name: .remoteShowNextSlide, object: nil)
        NotificationCenter.default.removeObserver(target, name: .remoteShowPreviousSlide, object: nil)
        NotificationCenter.default.removeObserver(target, name: .remoteShowBlackScreen, object: nil)
        NotificationCenter.default.removeObserver(target, name: .remoteShowWhiteScreen, object: nil)
    }
}




extension RemoteController: RemoteServiceDelegate {
    func peersChanged() {
        print("peersChanged")
        NotificationCenter.default.post(name: .remotePeersChanged, object: nil)
    }
    
    func browsingFailed(_ error: Error) {
        print("browsingFailed")
        NotificationCenter.default.post(name: .remoteBrowsingFailed, object: nil, userInfo: ["error": error])
    }
    
    func didSendVerfication(code: String, to peer: MCPeerID) {
        print("didSendVerfication")
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
        DisplayController.switchDisplayBlackCurtain(sender: self)
        NotificationCenter.default.post(name: .remoteShowBlackScreen, object: nil)
    }
    
    func shouldShowWhiteScreen() {
        DisplayController.switchDisplayWhiteCurtain(sender: self)
        NotificationCenter.default.post(name: .remoteShowWhiteScreen, object: nil)
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
}
