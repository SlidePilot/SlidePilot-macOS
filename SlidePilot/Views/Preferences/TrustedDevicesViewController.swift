//
//  TrustedDevicesViewController.swift
//  SlidePilot
//
//  Created by Pascal Braband on 18.10.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class TrustedDevicesViewController: NSViewController {

    @IBOutlet weak var trustedDevicesTable: NSTableView!
    
    let service: RemoteService = RemoteController.shared.service
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        trustedDevicesTable.delegate = self
        trustedDevicesTable.dataSource = self
    }
    
    
    @IBAction func removeTrustedPeer(_ sender: NSButton) {
        guard let cellView = sender.superview else { return }
        let index = trustedDevicesTable.row(for: cellView)
        let peer = service.trustedPeers[index]
        
        let alert: NSAlert = NSAlert()
        alert.messageText = NSLocalizedString("Remove Trusted Peer Message", comment: "Message for alert when removing trusted peer.")
        alert.informativeText = String(format: NSLocalizedString("Remove Trusted Peer Description", comment: "Description for alert when removing trusted peer."), peer.displayName)
        alert.alertStyle = .warning
        alert.addButton(withTitle: NSLocalizedString("OK", comment: "Title for ok button."))
        alert.addButton(withTitle: NSLocalizedString("Cancel", comment: "Title for cancel button."))
        guard let window = self.view.window else { return }
        alert.beginSheetModal(for: window) { (response) in
            if response == .alertFirstButtonReturn {
                // Remove and disconnect trusted peer
                self.service.disconnect(from: peer)
                self.trustedDevicesTable.reloadData()
            }
        }
//        let res = alert.runModal()
        
    }
    
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(self)
    }
}




extension TrustedDevicesViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let peer = service.trustedPeers[row]
        
        let cellIdentifierString = "TrustedDeviceCell"
        
        let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: cellIdentifierString)
        guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
        cellView.textField?.stringValue = peer.displayName
        
        if let button = cellView.subviews.first(where: { $0 is NSButton }) as? NSButton,
           button.identifier == NSUserInterfaceItemIdentifier("RemoveButton") {
            button.target = self
            button.action = #selector(removeTrustedPeer(_:))
        }
        
        return cellView
    }
}




extension TrustedDevicesViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return service.trustedPeers.count
    }
}
