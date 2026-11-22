//
//  FileObserver.swift
//  SlidePilot
//
//  Created by Pascal Braband on 05.10.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Foundation

/**
 Watches the file at a path and calls a block once the file has changed and settled.

 The path is watched, not just the file that was there when observing started. Tools like latexmk
 replace a file by renaming a new one over it, which leaves a watch on the old file deaf. Therefore
 the observer listens to the file (write, extend, delete, rename, attributes) and to its parent
 directory (entries created, removed or renamed), re-opens the file whenever it was replaced, and
 polls the path at a low rate as a safety net.

 The block is only called after the file stopped changing for `settleInterval`, so a burst of writes
 results in a single call. It is called on a private background queue. Observing stops when the
 observer is released.
 */
class FileObserver {

    /** State of a file on disk. Two equal fingerprints mean the file was not changed in between. */
    struct Fingerprint: Equatable {
        let device: dev_t
        let inode: ino_t
        let size: off_t
        let modificationSeconds: Int
        let modificationNanoseconds: Int

        init?(path: String) {
            var info = stat()
            guard stat(path, &info) == 0 else { return nil }
            device = info.st_dev
            inode = info.st_ino
            size = info.st_size
            modificationSeconds = info.st_mtimespec.tv_sec
            modificationNanoseconds = info.st_mtimespec.tv_nsec
        }

        func isSameFile(as other: Fingerprint?) -> Bool {
            return device == other?.device && inode == other?.inode
        }
    }


    private let path: String
    private let settleInterval: TimeInterval
    private let block: () -> Void
    private let queue = DispatchQueue(label: "SlidePilot.FileObserver")

    private var fileSource: DispatchSourceFileSystemObject?
    private var watchedFile: Fingerprint?
    private var directorySource: DispatchSourceFileSystemObject?
    private var pollTimer: DispatchSourceTimer?
    private var settleTask: DispatchWorkItem?

    /** Fingerprint seen at the last change, compared again after `settleInterval`. */
    private var pendingFingerprint: Fingerprint?
    /** Fingerprint of the last version the block was called for. */
    private var reportedFingerprint: Fingerprint?


    deinit {
        // Nothing else holds a reference now, so no handler can be using these
        fileSource?.cancel()
        directorySource?.cancel()
        pollTimer?.cancel()
        settleTask?.cancel()
    }


    /**
     - parameters:
        - URL: The file to observe.
        - settleInterval: How long the file must remain unchanged before `block` is called.
        - pollInterval: Interval of the safety-net poll of the path.
        - block: Called on a background queue, once per settled change.
     */
    init(URL: URL, settleInterval: TimeInterval = 0.4, pollInterval: TimeInterval = 2.0, block: @escaping ()->Void) {
        self.path = URL.path
        self.settleInterval = settleInterval
        self.block = block

        let directoryPath = URL.deletingLastPathComponent().path
        queue.sync {
            reportedFingerprint = Fingerprint(path: path)
            pendingFingerprint = reportedFingerprint
            rearmFileSource(force: true)

            directorySource = makeSource(path: directoryPath, eventMask: [.write, .delete, .rename]) { [weak self] _ in
                self?.fileDidChange()
            }

            let timer = DispatchSource.makeTimerSource(queue: queue)
            timer.schedule(deadline: .now() + pollInterval, repeating: pollInterval, leeway: .milliseconds(200))
            timer.setEventHandler { [weak self] in
                self?.poll()
            }
            timer.resume()
            pollTimer = timer
        }
    }




    // MARK: - Events

    private func fileDidChange(replaced: Bool = false) {
        rearmFileSource(force: replaced)
        pendingFingerprint = Fingerprint(path: path)
        scheduleSettleCheck()
    }


    private func poll() {
        // Only act on changes that no event reported and that are not already being waited for
        let current = Fingerprint(path: path)
        if current != reportedFingerprint, settleTask == nil {
            fileDidChange()
        }
    }


    private func scheduleSettleCheck() {
        settleTask?.cancel()
        let task = DispatchWorkItem { [weak self] in
            self?.settleCheck()
        }
        settleTask = task
        queue.asyncAfter(deadline: .now() + settleInterval, execute: task)
    }


    private func settleCheck() {
        settleTask = nil
        rearmFileSource(force: false)
        let current = Fingerprint(path: path)

        // Still changing: wait for the next quiet period
        guard current == pendingFingerprint else {
            pendingFingerprint = current
            scheduleSettleCheck()
            return
        }

        // Missing (an event or the poll announces its return) or unchanged
        guard let settled = current, settled != reportedFingerprint else { return }
        reportedFingerprint = settled
        block()
    }




    // MARK: - Sources

    /** Watches the file currently at `path`, unless it is the one already watched. */
    private func rearmFileSource(force: Bool) {
        let current = Fingerprint(path: path)
        guard force || fileSource == nil || !(current?.isSameFile(as: watchedFile) ?? false) else { return }

        fileSource?.cancel()
        fileSource = nil
        watchedFile = nil
        guard current != nil else { return }

        fileSource = makeSource(path: path, eventMask: [.write, .extend, .delete, .rename, .attrib, .link, .revoke]) { [weak self] events in
            self?.fileDidChange(replaced: !events.isDisjoint(with: [.delete, .rename, .revoke]))
        }
        if fileSource != nil {
            watchedFile = current
        }
    }


    private func makeSource(path: String, eventMask: DispatchSource.FileSystemEvent, handler: @escaping (DispatchSource.FileSystemEvent) -> Void) -> DispatchSourceFileSystemObject? {
        let fileDescriptor = open(path, O_EVTONLY)
        guard fileDescriptor >= 0 else { return nil }
        let source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileDescriptor, eventMask: eventMask, queue: queue)
        source.setEventHandler { [unowned source] in
            handler(source.data)
        }
        source.setCancelHandler {
            close(fileDescriptor)
        }
        source.resume()
        return source
    }

}
