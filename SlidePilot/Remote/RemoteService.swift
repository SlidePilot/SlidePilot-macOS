//
//  RemoteService.swift
//  SlidePilot
//
//  Created by Pascal Braband on 08.10.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa
import MultipeerConnectivity

class RemoteService: NSObject {
    
    // Identification for the Bonjour service
    private let serviceName = "slidepilot-ctrl"
    
    // The devices peer ID
    private let peerID = MCPeerID(displayName: Host.current().localizedName ?? "<Device Name>")
    
    private let serviceBrowser: MCNearbyServiceBrowser
    
    lazy var session: MCSession = {
        let session = MCSession(peer: self.peerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()
    
    var delegate: RemoteServiceDelegate?
    
    
    // MARK: Peers
    
    var peers = [Connection]()
    var trustedPeers = [MCPeerID]() {
        didSet {
            guard let data = NSKeyedArchiver.archive(object: self.trustedPeers) else { return }
            UserDefaults.standard.set(data, forKey: trustedPeersKey)
            UserDefaults.standard.synchronize()
        }
    }
    let trustedPeersKey = "TrustedPeerKey"
    
    struct Connection {
        var peer: MCPeerID
        var state: PeerState
        
        enum PeerState {
            case available, pending, connected
        }
    }
    
    
    
    
    override init() {
        serviceBrowser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceName)
        
        super.init()
        
        serviceBrowser.delegate = self
        serviceBrowser.startBrowsingForPeers()
        
        // Load trusted peers from user defaults
        if let storedTrustedPeersData = UserDefaults.standard.data(forKey: trustedPeersKey) {
            var storedTrustedPeers: [MCPeerID]!
            if #available(OSX 10.13, *) {
                guard let stored = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, MCPeerID.self], from: storedTrustedPeersData) as? [MCPeerID] else { return }
                storedTrustedPeers = stored
            } else {
                guard let stored = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(storedTrustedPeersData) as? [MCPeerID] else { return }
                storedTrustedPeers = stored
            }
            self.trustedPeers = storedTrustedPeers
        }
    }
    
    
    deinit {
        serviceBrowser.stopBrowsingForPeers()
    }
    
    
    
    
    // MARK: - Message Sending
    
    private func send(message: Message) {
        print("Send message to \(session.connectedPeers.count) peers:\n\(message)")
        
        if session.connectedPeers.count > 0 {
            do {
                guard let messageData = message.data() else { return }
                try self.session.send(messageData, toPeers: session.connectedPeers, with: .reliable)
            } catch {
                print("Error for sending: \(error)")
            }
        }
    }
    
    
    public func send(currentSlide slideImage: NSImage) {
        guard hasConnections() else { return }
        DispatchQueue.global().async {
            guard let imageData = slideImage.compressed() else { return }
            self.send(message: Message(command: .currentSlide, payload: imageData))
        }
    }
    
    
    public func send(nextSlide slideImage: NSImage) {
        guard hasConnections() else { return }
        DispatchQueue.global().async {
            guard let imageData = slideImage.compressed() else { return }
            self.send(message: Message(command: .nextSlide, payload: imageData))
        }
    }
    
    
    public func send(notesSlide slideImage: NSImage) {
        guard hasConnections() else { return }
        DispatchQueue.global().async {
            guard let imageData = slideImage.compressed() else { return }
            self.send(message: Message(command: .noteSlide, payload: imageData))
        }
    }
    
    
    public func send(meta: [String: Any]) {
        guard hasConnections() else { return }
        DispatchQueue.global().async {
            guard let metaData = try? JSONSerialization.data(withJSONObject: meta, options: []) else { return }
            self.send(message: Message(command: .meta, payload: metaData))
        }
    }
    
    
    public func send(notesText: NSAttributedString) {
        guard hasConnections() else { return }
        DispatchQueue.global().async {
            guard let textData = try? notesText.data(from: NSRange(location: 0, length: notesText.length),
                                                     documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]) else { return }
            self.send(message: Message(command: .notesText, payload: textData))
        }
    }
    
    
    
    
    // MARK: - Message Processing
    
    private func process(message: Message) {
        switch message.command {
        case .disconnect:
            guard let messageData = message.payload else { return }
            guard let peer = NSKeyedUnarchiver.unarchive(data: messageData, of: MCPeerID.self) else { return }
            disconnect(from: peer)
            
        case .showNextSlide:
            DispatchQueue.main.async { self.delegate?.shouldShowNextSlide() }
            
        case .showPreviousSlide:
            DispatchQueue.main.async { self.delegate?.shouldShowPreviousSlide() }
            
        case .showBlackScreen:
            DispatchQueue.main.async { self.delegate?.shouldShowBlackScreen() }
            
        case .showWhiteScreen:
            DispatchQueue.main.async { self.delegate?.shouldShowWhiteScreen() }
            
        case .hideCurtain:
            DispatchQueue.main.async { self.delegate?.shouldHideCutrain() }
            
        case .pointerPosition:
            guard let messageData = message.payload else { return }
            guard let positionString = String(data: messageData, encoding: .utf8) else { return }
            let position = NSPointFromString(positionString)
            print(position)
            
        default:
            return
        }
    }
    
    
    
    
    // MARK: - Connection
    
    func connect(to peerID: MCPeerID) {
        serviceBrowser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
        add(peer: peerID, state: .pending)
    }
    
    
    func verifyConenction(to peerID: MCPeerID) {
        // Only continue if peer is still connected
        guard session.connectedPeers.contains(peerID) else { return }
        
        // Add peer as connected
        add(peer: peerID, state: .connected)
        
        // Add to trusted peers
        addTrusted(peer: peerID)
        
        // Notify peer that connection was established
        guard let peerData = NSKeyedArchiver.archive(object: self.peerID) else { return }
        send(message: Message(command: .connectionAccepted, payload: peerData))
    }
    
    
    func disconnect(from peerID: MCPeerID) {
        // Send a message, that this peer should disconnect itself
        send(message: Message(command: .disconnect, payload: nil))
        
        // Remove from trusted peers
        removeTrusted(peer: peerID)
    }
    
    
    let verificationCodeLength = 4
    
    func generateVerificationCode() -> String {
        let letters = "0123456789"
        return String((0..<verificationCodeLength).map{ _ in letters.randomElement()! })
    }
    
    
    private func hasConnections() -> Bool {
        return self.session.connectedPeers.count > 0
    }
    
    
    
    
    // MARK: - Peer Lists
    
    private func add(peer: MCPeerID, state: Connection.PeerState) {
        let peerIndex = peers.firstIndex(where: { $0.peer == peer })
        switch state {
        case .available:
            if peerIndex == nil {
                // Only add connection if it doesn't exist
                peers.append(Connection(peer: peer, state: .available))
            }
            
        case .pending:
            if let index = peerIndex {
                // If connection already exists, change it's state to pending
                peers[index].state = .pending
            } else {
                // Add connection if it does not exist
                peers.append(Connection(peer: peer, state: .pending))
            }
            
        case .connected:
            if let index = peerIndex {
                // If connection already exists, change it's state to connected
                peers[index].state = .connected
            } else {
                // Add connection if it does not exist
                peers.append(Connection(peer: peer, state: .connected))
            }
        }
        peersChanged()
    }
    
    
    private func remove(peer: MCPeerID) {
        guard let index = peers.firstIndex(where: { $0.peer == peer }) else { return }
        peers.remove(at: index)
        peersChanged()
    }
    
    
    private func changeState(for peer: MCPeerID, to newState: Connection.PeerState) {
        guard let index = peers.firstIndex(where: { $0.peer == peer }) else { return }
        peers[index].state = newState
        peersChanged()
    }
    
    
    private func addTrusted(peer: MCPeerID) {
        if trustedPeers.firstIndex(of: peer) == nil {
            trustedPeers.append(peer)
        }
    }
    
    
    private func removeTrusted(peer: MCPeerID) {
        if let index = trustedPeers.firstIndex(of: peer) {
            trustedPeers.remove(at: index)
        }
    }
    
    
    private func peersChanged() {
        DispatchQueue.main.async {
            self.delegate?.peersChanged()
        }
    }
}



extension RemoteService: MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        delegate?.browsingFailed(error)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("foundPeer: \(peerID)")
        
        if trustedPeers.contains(peerID) {
            // If peer is a trusted one, connect directly
            print("Trusted Peer: Trying to connect ...")
            serviceBrowser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
        } else {
            // Add available peer
            add(peer: peerID, state: .available)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("lostPeer: \(peerID)")
        
        // Remove peer from available peers
        remove(peer: peerID)
    }
}



extension RemoteService: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("peer \(peerID) didChangeState: \(state)")
        print("Connected devices: \(session.connectedPeers.map({ $0.displayName }))")
        
        if state == .connected {
            // If peer is a trusted one, skip verification
            if trustedPeers.contains(peerID) {
                add(peer: peerID, state: .connected)
                
                // Notify peer that connection was established
                guard let peerData = NSKeyedArchiver.archive(object: self.peerID) else { return }
                send(message: Message(command: .connectionAccepted, payload: peerData))
            }
            
            // Otherwise verify device using verifaction code
            else {
                // Add peer to pending (waiting for verification)
                add(peer: peerID, state: .pending)
                
                // Send verfication code
                let code = generateVerificationCode()
                send(message: Message(command: .code, payload: code.data(using: .utf8)))
                
                DispatchQueue.main.async {
                    self.delegate?.didSendVerfication(code: code, to: peerID)
                }
            }
        }
        
        else if state == .notConnected {
            // Remove peer if connection failed or was cancelled
            remove(peer: peerID)
            add(peer: peerID, state: .available)
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("Reveiving ...")
        guard let message = Message(data: data) else { return }
        print("Received message: \(message)")
        
        process(message: message)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) { }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) { }
}




protocol RemoteServiceDelegate {
    func peersChanged()
    func browsingFailed(_ error: Error)
    func didSendVerfication(code: String, to peer: MCPeerID)
    func shouldShowNextSlide()
    func shouldShowPreviousSlide()
    func shouldShowBlackScreen()
    func shouldShowWhiteScreen()
    func shouldHideCutrain()
}
