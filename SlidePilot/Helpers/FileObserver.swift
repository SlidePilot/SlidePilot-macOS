//
//  FileObserver.swift
//  SlidePilot
//
//  Created by Pascal Braband on 05.10.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class FileObserver {
    
    private let fileDescriptor: CInt
    private let source: DispatchSourceProtocol
    
    private var lastModified: Date?
    
    
    deinit {
        self.source.cancel()
        close(fileDescriptor)
    }
    
    
    init(URL: URL, block: @escaping ()->Void) {
        self.fileDescriptor = open(URL.path, O_EVTONLY)
        self.source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: self.fileDescriptor, eventMask: .write, queue: DispatchQueue.global())
        self.source.setEventHandler { [weak self] in
            // Only call block, if file really changed (using modification date)
            guard let modificationDate = self?.fileModificationDate(url: URL) else { return }
            if modificationDate != self?.lastModified {
                self?.lastModified = modificationDate
                block()
            }
        }
        self.source.resume()
    }
    
    
    func fileModificationDate(url: URL) -> Date? {
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: url.path)
            return attr[FileAttributeKey.modificationDate] as? Date
        } catch {
            return nil
        }
    }
    
    
    func cancel() {
        self.source.cancel()
        close(fileDescriptor)
    }
    
}
