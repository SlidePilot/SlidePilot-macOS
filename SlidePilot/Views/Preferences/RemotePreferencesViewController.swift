//
//  RemotePreferencesViewController.swift
//  SlidePilot
//
//  Created by Pascal Braband on 07.10.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa
import Preferences
import MultipeerConnectivity

class RemotePreferencesViewController: NSViewController, PreferencePane {
    
    let preferencePaneIdentifier = Preferences.PaneIdentifier.remote
    let preferencePaneTitle = NSLocalizedString("Remote", comment: "Title for remote preferences.")
    let toolbarItemIcon = NSImage(named: "RemoteIcon")!

    override var nibName: NSNib.Name? { "RemotePreferences" }
    
    
    // MARK: - UI Elements
    @IBOutlet var peerTable: NSTableView!
    
    
    let service: RemoteService = RemoteController.shared.service
        
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        peerTable.delegate = self
        peerTable.dataSource = self
        
        // Subscribe to remote controller events
        RemoteController.shared.subscribeRemotePeersChanged(target: self, action: #selector(peersChanged(_:)))
        RemoteController.shared.subscribeRemoteDidSendVerification(target: self, action: #selector(didSendVerfication(_:)))
    }
    
    
    @IBAction func connectPeer(_ sender: NSButton) {
        guard let cellView = sender.superview else { return }
        let index = peerTable.row(for: cellView)
        
        service.connect(to: service.peers[index].peer)
    }
    
    
    @IBAction func disconnectPeer(_ sender: NSButton) {
        guard let cellView = sender.superview else { return }
        let index = peerTable.row(for: cellView)
        
        service.disconnect(from: service.peers[index].peer)
    }
    
    
    @IBAction func showTrustedDevices(_ sender: NSButton) {
        // Show trusted devices view
        let trustedDevicesVC = TrustedDevicesViewController()
        presentAsSheet(trustedDevicesVC)
    }
    
    
    @objc func peersChanged(_ notification: Notification) {
        peerTable.reloadData()
    }
    
    
    @objc func didSendVerfication(_ notification: Notification) {
        guard let code = notification.userInfo?["code"] as? String else { return }
        guard let peer = notification.userInfo?["peer"] as? MCPeerID else { return }
        
        // Show verification view
        let remoteVerificationVC = RemoteVerificationViewController()
        remoteVerificationVC.code = code
        remoteVerificationVC.deviceName = peer.displayName
        remoteVerificationVC.completiton = { isVerified in
            if isVerified {
                print("### Verify")
                self.service.verifyConenction(to: peer)
            } else {
                print("### No trust")
                self.service.disconnect(from: peer)
            }
        }
        
        presentAsSheet(remoteVerificationVC)
    }
}




extension RemotePreferencesViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let connection = service.peers[row]
        
        var cellIdentifierString = ""
        switch connection.state {
        case .available: cellIdentifierString = "AvailableDeviceCell"
        case .pending: cellIdentifierString = "PendingDeviceCell"
        case .connected: cellIdentifierString = "ConnectedDeviceCell"
        }
        
        let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: cellIdentifierString)
        guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
        cellView.textField?.stringValue = connection.peer.displayName
        
        // Start spinner if available
        if let spinner = cellView.subviews.first(where: { $0 is NSProgressIndicator }) as? NSProgressIndicator {
            spinner.startAnimation(self)
        }
        
        if let button = cellView.subviews.first(where: { $0 is NSButton }) as? NSButton {
            button.target = self
            if button.identifier == NSUserInterfaceItemIdentifier("ConnectButton") {
                button.action = #selector(connectPeer(_:))
            } else if button.identifier == NSUserInterfaceItemIdentifier("DisconnectButton") {
                button.action = #selector(disconnectPeer(_:))
            }
        }
        
        return cellView
    }
}




extension RemotePreferencesViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return service.peers.count
    }
}
