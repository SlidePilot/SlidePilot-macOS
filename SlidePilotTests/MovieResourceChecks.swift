// Standalone integration checks; see MovieFixtures/README.md.
import Foundation
import PDFKit
@main
struct MovieResourceChecks {
static func main() {
let fixtureDirectory = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
let linked = PDFDocument(url: URL(fileURLWithPath: fixtureDirectory.appendingPathComponent("linked-movie.pdf").path))!
let resources = linked.page(at: 0)!.movieResources()
precondition(resources.count == 2)
precondition(resources[0].bounds == CGRect(x: 10, y: 20, width: 100, height: 100))
let linkedURL = PDFMovieFiles.shared.url(for: resources[0].file, document: linked)!
precondition(linkedURL == fixtureDirectory.appendingPathComponent("movie with spaces.mp4"))
let embedded = PDFDocument(url: URL(fileURLWithPath: fixtureDirectory.appendingPathComponent("embedded-movie.pdf").path))!
let movie = embedded.page(at: 0)!.movieResources()[0]
let first = PDFMovieFiles.shared.url(for: movie.file, document: embedded)!
let second = PDFMovieFiles.shared.url(for: movie.file, document: embedded)!
precondition(first == second)
precondition(try! Data(contentsOf: first) == Data("movie-bytes".utf8))
_ = PDFMovieFiles.shared.url(for: resources[0].file, document: linked)
precondition(!FileManager.default.fileExists(atPath: first.path))
print("Passed: annotation discovery, bounds, linked filenames, embedded extraction, shared URLs, cleanup")

}
}
