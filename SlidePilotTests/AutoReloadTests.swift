//
//  AutoReloadTests.swift
//  SlidePilotTests
//
//  Tests the file watching and validation behind the automatic reload of a rebuilt PDF.
//

import XCTest
import PDFKit
@testable import SlidePilot

class AutoReloadTests: XCTestCase {

    private var directory: URL!
    private var fileURL: URL!

    /** Short settle interval, and a poll so slow that only file events can trigger a reload. */
    private let settleInterval: TimeInterval = 0.25
    private let pollInterval: TimeInterval = 100

    override func setUp() {
        directory = FileManager.default.temporaryDirectory.appendingPathComponent("AutoReloadTests-\(UUID().uuidString)", isDirectory: true)
        try! FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        fileURL = directory.appendingPathComponent("slides.pdf")
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: directory)
    }




    // MARK: - Helpers

    /** Creates a PDF with the given number of pages; `label` makes the content unique. */
    private func makePDF(pages: Int, label: String = UUID().uuidString) -> Data {
        let data = NSMutableData()
        var mediaBox = CGRect(x: 0, y: 0, width: 400, height: 300)
        let consumer = CGDataConsumer(data: data as CFMutableData)!
        let context = CGContext(consumer: consumer, mediaBox: &mediaBox, nil)!
        for page in 0..<pages {
            context.beginPDFPage(nil)
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: false)
            ("\(label) page \(page + 1)" as NSString).draw(at: CGPoint(x: 20, y: 150), withAttributes: [.font: NSFont.systemFont(ofSize: 18)])
            NSGraphicsContext.restoreGraphicsState()
            context.endPDFPage()
        }
        context.closePDF()
        return data as Data
    }

    /** Rewrites the file in place: same inode, truncated first. */
    private func writeInPlace(_ data: Data) {
        let handle = try! FileHandle(forWritingTo: fileURL)
        handle.truncateFile(atOffset: 0)
        handle.write(data)
        handle.closeFile()
    }

    /** Replaces the file like latexmk does: write a new file next to it, then rename it over. */
    private func replaceByRename(_ data: Data) {
        let temporary = directory.appendingPathComponent("build-\(UUID().uuidString).pdf")
        try! data.write(to: temporary)
        XCTAssertEqual(rename(temporary.path, fileURL.path), 0)
    }

    private func spin(_ seconds: TimeInterval) {
        RunLoop.current.run(until: Date().addingTimeInterval(seconds))
    }

    @discardableResult
    private func spin(until condition: () -> Bool, timeout: TimeInterval = 5) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition() && Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.02))
        }
        return condition()
    }

    /** Starts a reloader on `fileURL` that records the page count of every delivered document. */
    private func makeReloader(shownData: Data?, delivered: @escaping (PDFDocument) -> Void) -> DocumentReloader {
        return DocumentReloader(url: fileURL, shownData: shownData,
                                settleInterval: settleInterval, pollInterval: pollInterval,
                                retryInterval: 0.1, retryDuration: 2.0,
                                callbackQueue: .main, onReload: delivered)
    }




    // MARK: - Validation

    func testLoaderAcceptsCompletePDF() {
        try! makePDF(pages: 3).write(to: fileURL)
        let loaded = PDFLoader.loadCompleteDocument(at: fileURL)
        XCTAssertEqual(loaded?.document.pageCount, 3)
        XCTAssertNil(loaded?.document.documentURL)
    }


    func testLoaderRejectsIncompleteFiles() {
        let valid = makePDF(pages: 3)

        // Missing
        XCTAssertNil(PDFLoader.loadCompleteDocument(at: fileURL))

        // Empty
        try! Data().write(to: fileURL)
        XCTAssertNil(PDFLoader.loadCompleteDocument(at: fileURL))

        // Half-written
        try! valid.prefix(valid.count / 2).write(to: fileURL)
        XCTAssertNil(PDFLoader.loadCompleteDocument(at: fileURL))

        // Cut off just before the end marker
        try! valid.prefix(valid.count - 8).write(to: fileURL)
        XCTAssertNil(PDFLoader.loadCompleteDocument(at: fileURL))

        // Header and end marker, but garbage in between
        try! Data("%PDF-1.5\n".utf8 + Data(repeating: 0x41, count: 5000) + Data("\n%%EOF\n".utf8)).write(to: fileURL)
        XCTAssertNil(PDFLoader.loadCompleteDocument(at: fileURL))
    }


    func testCompletenessCheck() {
        let valid = makePDF(pages: 1)
        XCTAssertTrue(PDFLoader.isCompletePDF(valid))
        XCTAssertFalse(PDFLoader.isCompletePDF(valid.prefix(valid.count - 10)))
        XCTAssertFalse(PDFLoader.isCompletePDF(Data("Hello world, this is not a PDF %%EOF".utf8)))
    }




    // MARK: - File observer

    func testObserverReportsInPlaceRewriteOnce() {
        try! makePDF(pages: 1).write(to: fileURL)
        var calls = 0
        let observer = FileObserver(URL: fileURL, settleInterval: settleInterval, pollInterval: pollInterval) {
            DispatchQueue.main.async { calls += 1 }
        }

        // A burst of writes, faster than the settle interval
        for index in 0..<8 {
            writeInPlace(makePDF(pages: 1, label: "burst \(index)"))
            spin(0.05)
        }
        XCTAssertTrue(spin(until: { calls >= 1 }))
        spin(0.6)
        XCTAssertEqual(calls, 1)
        withExtendedLifetime(observer) {}
    }


    func testObserverSurvivesRepeatedReplacement() {
        try! makePDF(pages: 1).write(to: fileURL)
        var calls = 0
        let observer = FileObserver(URL: fileURL, settleInterval: settleInterval, pollInterval: pollInterval) {
            DispatchQueue.main.async { calls += 1 }
        }

        // Each replacement gives the path a new file; the observer must follow it every time
        for round in 1...3 {
            replaceByRename(makePDF(pages: round))
            XCTAssertTrue(spin(until: { calls == round }), "Replacement \(round) was not reported")
        }

        // And an in-place write to the latest file
        writeInPlace(makePDF(pages: 4))
        XCTAssertTrue(spin(until: { calls == 4 }))
        withExtendedLifetime(observer) {}
    }


    func testObserverIgnoresUnchangedFile() {
        try! makePDF(pages: 1).write(to: fileURL)
        var calls = 0
        let observer = FileObserver(URL: fileURL, settleInterval: settleInterval, pollInterval: 0.2) {
            DispatchQueue.main.async { calls += 1 }
        }
        // Other files in the same folder, and polls of the unchanged file
        try! Data("aux".utf8).write(to: directory.appendingPathComponent("slides.aux"))
        spin(1.0)
        XCTAssertEqual(calls, 0)
        withExtendedLifetime(observer) {}
    }




    // MARK: - Reloader

    func testReloadAfterInPlaceRewrite() {
        let initial = makePDF(pages: 2)
        try! initial.write(to: fileURL)
        var pageCounts = [Int]()
        let reloader = makeReloader(shownData: initial) { pageCounts.append($0.pageCount) }

        writeInPlace(makePDF(pages: 3))
        XCTAssertTrue(spin(until: { pageCounts == [3] }))
        withExtendedLifetime(reloader) {}
    }


    func testReloadAfterAtomicReplace() {
        let initial = makePDF(pages: 2)
        try! initial.write(to: fileURL)
        var pageCounts = [Int]()
        let reloader = makeReloader(shownData: initial) { pageCounts.append($0.pageCount) }

        replaceByRename(makePDF(pages: 3))
        XCTAssertTrue(spin(until: { pageCounts == [3] }))
        replaceByRename(makePDF(pages: 5))
        XCTAssertTrue(spin(until: { pageCounts == [3, 5] }))
        withExtendedLifetime(reloader) {}
    }


    func testReloadAfterDeleteAndRecreate() {
        let initial = makePDF(pages: 2)
        try! initial.write(to: fileURL)
        var pageCounts = [Int]()
        let reloader = makeReloader(shownData: initial) { pageCounts.append($0.pageCount) }

        try! FileManager.default.removeItem(at: fileURL)
        spin(0.6)
        XCTAssertEqual(pageCounts, [])

        try! makePDF(pages: 4).write(to: fileURL)
        XCTAssertTrue(spin(until: { pageCounts == [4] }))
        withExtendedLifetime(reloader) {}
    }


    func testBrokenFileIsNeverDelivered() {
        let initial = makePDF(pages: 2)
        try! initial.write(to: fileURL)
        var pageCounts = [Int]()
        let reloader = makeReloader(shownData: initial) { pageCounts.append($0.pageCount) }

        // A failed build: a truncated PDF stays in place for a while
        let next = makePDF(pages: 6)
        replaceByRename(next.prefix(next.count / 2))
        spin(1.0)
        XCTAssertEqual(pageCounts, [])

        // Garbage written in place
        writeInPlace(Data(repeating: 0x20, count: 3000))
        spin(1.0)
        XCTAssertEqual(pageCounts, [])

        // Then a good build
        replaceByRename(next)
        XCTAssertTrue(spin(until: { pageCounts == [6] }))
        spin(0.5)
        XCTAssertEqual(pageCounts, [6])
        withExtendedLifetime(reloader) {}
    }


    func testIncompleteRewriteThenCompletion() {
        // An in-place rewrite that pauses half-way must not be shown until it is complete
        let initial = makePDF(pages: 2)
        try! initial.write(to: fileURL)
        var pageCounts = [Int]()
        let reloader = makeReloader(shownData: initial) { pageCounts.append($0.pageCount) }

        let next = makePDF(pages: 7)
        writeInPlace(next.prefix(next.count - 20))
        spin(0.5)
        XCTAssertEqual(pageCounts, [])
        writeInPlace(next)
        XCTAssertTrue(spin(until: { pageCounts == [7] }))
        withExtendedLifetime(reloader) {}
    }


    func testRapidWritesReloadOnce() {
        let initial = makePDF(pages: 1)
        try! initial.write(to: fileURL)
        var pageCounts = [Int]()
        let reloader = makeReloader(shownData: initial) { pageCounts.append($0.pageCount) }

        for pages in 2...9 {
            writeInPlace(makePDF(pages: pages))
            spin(0.04)
        }
        XCTAssertTrue(spin(until: { !pageCounts.isEmpty }))
        spin(0.8)
        XCTAssertEqual(pageCounts, [9])
        withExtendedLifetime(reloader) {}
    }


    func testIdenticalContentIsNotDelivered() {
        let initial = makePDF(pages: 2)
        try! initial.write(to: fileURL)
        var pageCounts = [Int]()
        let reloader = makeReloader(shownData: initial) { pageCounts.append($0.pageCount) }

        replaceByRename(initial)
        spin(1.0)
        XCTAssertEqual(pageCounts, [])
        withExtendedLifetime(reloader) {}
    }


    func testCancelledReloaderDeliversNothing() {
        let initial = makePDF(pages: 2)
        try! initial.write(to: fileURL)
        var pageCounts = [Int]()
        let reloader = makeReloader(shownData: initial) { pageCounts.append($0.pageCount) }
        reloader.cancel()

        replaceByRename(makePDF(pages: 3))
        spin(1.0)
        XCTAssertEqual(pageCounts, [])
    }

}
